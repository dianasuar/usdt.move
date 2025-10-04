module sportsbook_platform::custodial_usdt {
    use std::signer;
    use std::vector;
    use std::option;
    use std::error;

    /// Error codes
    const E_NOT_ADMIN: u64 = 1;
    const E_NO_FUNDS: u64 = 2;
    const E_BAD_RANGE: u64 = 3;
    const E_K_TOO_BIG: u64 = 4;
    const E_ALREADY_INIT: u64 = 5;

    /// Marks that this address is the admin (stored at @sportsbook_platform)
    struct Admin has key {}

    /// Simple custodial ledger: parallel arrays addrs[i] -> amts[i]
    struct Balances has key {
        addrs: vector<address>,
        amts:  vector<u128>,
    }

    /// One-time setup by admin (your named address in Move.toml)
    public entry fun initialize(admin: &signer) {
        assert!(signer::address_of(admin) == @sportsbook_platform, error::permission_denied(E_NOT_ADMIN));
        assert!(!exists<Admin>(@sportsbook_platform), E_ALREADY_INIT);
        move_to(admin, Admin {});
        move_to(admin, Balances {
            addrs: vector::empty<address>(),
            amts:  vector::empty<u128>()
        });
    }

    /// Read balance

#[view]
public fun balance_of(addr: address): u128 acquires Balances {
        let b = borrow_global<Balances>(@sportsbook_platform);
        let idx_opt = find_index(&b.addrs, addr);
        if (option::is_some(&idx_opt)) {
            let i_ref = option::borrow(&idx_opt);
            let i = *i_ref;
            *vector::borrow(&b.amts, i)
        } else {
            0u128
        }
    }

    /// Credit someone (any signer allowed; customize if you want only admin)
    public entry fun deposit(_any: &signer, to: address, amount: u128) acquires Balances {
        let b = borrow_global_mut<Balances>(@sportsbook_platform);
        let i = ensure_holder(b, to);
        let cur = *vector::borrow(&b.amts, i);
        *vector::borrow_mut(&mut b.amts, i) = cur + amount;
    }

    /// Debit self
    public entry fun withdraw(user: &signer, amount: u128) acquires Balances {
        let ua = signer::address_of(user);
        let b = borrow_global_mut<Balances>(@sportsbook_platform);

        let idx_opt = find_index(&b.addrs, ua);
        assert!(option::is_some(&idx_opt), error::invalid_argument(E_NO_FUNDS));
        let i_ref = option::borrow(&idx_opt);
        let i = *i_ref;

        let cur = *vector::borrow(&b.amts, i);
        assert!(cur >= amount, error::invalid_argument(E_NO_FUNDS));
        *vector::borrow_mut(&mut b.amts, i) = cur - amount;
    }

    /// Transfer between two addresses inside this custodial ledger
    public entry fun transfer(from: &signer, to: address, amount: u128) acquires Balances {
        let fa = signer::address_of(from);
        let b = borrow_global_mut<Balances>(@sportsbook_platform);

        // debit sender
        let fi = must_index(b, fa);
        let fcur = *vector::borrow(&b.amts, fi);
        assert!(fcur >= amount, error::invalid_argument(E_NO_FUNDS));
        *vector::borrow_mut(&mut b.amts, fi) = fcur - amount;

        // credit receiver
        let ti = ensure_holder(b, to);
        let tcur = *vector::borrow(&b.amts, ti);
        *vector::borrow_mut(&mut b.amts, ti) = tcur + amount;
    }

    /// ADMIN: reset a single address to new_amount
    public entry fun admin_reset_one(admin: &signer, who: address, new_amount: u128) acquires Balances {
        assert_admin(admin);
        let b = borrow_global_mut<Balances>(@sportsbook_platform);
        let i = ensure_holder(b, who);
        *vector::borrow_mut(&mut b.amts, i) = new_amount;
    }

    /// ADMIN: reset ALL holders to new_amount (careful; heavy if many holders)
    public entry fun admin_reset_all(admin: &signer, new_amount: u128) acquires Balances {
        assert_admin(admin);
        let b = borrow_global_mut<Balances>(@sportsbook_platform);
        let n = vector::length(&b.amts);
        let i = 0u64;
        while (i < n) {
            *vector::borrow_mut(&mut b.amts, i) = new_amount;
            i = i + 1;
        };
    }

    /// ADMIN: reset top K holders by balance to new_amount
    public entry fun admin_reset_top_k(admin: &signer, k: u64, new_amount: u128) acquires Balances {
        assert_admin(admin);

        // read-only pass to select top-k indices
        let b_ro = borrow_global<Balances>(@sportsbook_platform);
        let total = vector::length(&b_ro.amts);
        assert!(k <= total, error::invalid_argument(E_K_TOO_BIG));

        let mut_top_idx = vector::empty<u64>();
        let mut_top_val = vector::empty<u128>();

        let i = 0u64;
        while (i < total) {
            let v = *vector::borrow(&b_ro.amts, i);
            if (vector::length(&mut_top_idx) < k) {
                vector::push_back(&mut mut_top_idx, i);
                vector::push_back(&mut mut_top_val, v);
            } else {
                // find min inside current top
                let m = 0u64;
                let j = 1u64;
                let tlen = vector::length(&mut_top_val);
                while (j < tlen) {
                    if (*vector::borrow(&mut_top_val, j) < *vector::borrow(&mut_top_val, m)) { m = j; };
                    j = j + 1;
                };
                if (v > *vector::borrow(&mut_top_val, m)) {
                    *vector::borrow_mut(&mut mut_top_val, m) = v;
                    *vector::borrow_mut(&mut mut_top_idx, m) = i;
                };
            };
            i = i + 1;
        };

        // write pass
        let b = borrow_global_mut<Balances>(@sportsbook_platform);
        let tlen2 = vector::length(&mut_top_idx);
        let t = 0u64;
        while (t < tlen2) {
            let idx = *vector::borrow(&mut_top_idx, t);
            *vector::borrow_mut(&mut b.amts, idx) = new_amount;
            t = t + 1;
        };
    }

    /// --- helpers ---

    fun assert_admin(s: &signer) {
        assert!(
            signer::address_of(s) == @sportsbook_platform && exists<Admin>(@sportsbook_platform),
            error::permission_denied(E_NOT_ADMIN)
        );
    }

    /// linear search for index (small/simple)
    fun find_index(addrs: &vector<address>, who: address): option::Option<u64> {
        let n = vector::length(addrs);
        let i = 0u64;
        while (i < n) {
            if (*vector::borrow(addrs, i) == who) {
                return option::some(i);
            };
            i = i + 1;
        };
        option::none()
    }

    /// ensure entry exists, return its index
    fun ensure_holder(b: &mut Balances, who: address): u64 {
        let idx_opt = find_index(&b.addrs, who);
        if (option::is_some(&idx_opt)) {
            let i_ref = option::borrow(&idx_opt);
            *i_ref
        } else {
            vector::push_back(&mut b.addrs, who);
            vector::push_back(&mut b.amts, 0u128);
            vector::length(&b.addrs) - 1
        }
    }

    /// must exist or abort
    fun must_index(b: &mut Balances, who: address): u64 {
        let idx_opt = find_index(&b.addrs, who);
        if (option::is_some(&idx_opt)) {
            let i_ref = option::borrow(&idx_opt);
            *i_ref
        } else {
            abort E_NO_FUNDS
        }
    }
}

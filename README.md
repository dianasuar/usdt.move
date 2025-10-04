#usdt.move
---

````markdown
# 🪙 Custodial USDT — Aptos Move Token

A **centralized / operator-controlled** USDT-like token built entirely in **Move** for the **Aptos** blockchain.  
It’s designed for platforms such as sportsbooks, gaming apps, and exchanges that need **instant balance resets**, **manual control**, and **off-chain accounting syncs** — without exposing Mint/Burn logic publicly.

---

## 🚀 Features

- ✅ **Admin-owned ledger** (no CoinStore, all balances live under module storage)
- 🔁 **Deposit / Withdraw / Transfer** between users
- 🔐 **Admin-level control**
  - Reset **any user’s** balance
  - Reset **all** balances at once
  - Reset **top-K holders’** balances (for leaderboard/game resets)
- 🧠 Uses Move’s `vector` storage and simple indexing — clean and fast for prototypes
- ⚙️ Compatible with Aptos CLI & Testnet explorer

---

## 📦 Module Details

| Field | Value |
|-------|-------|
| **Module Address** | `0xfc26c5948f1865f748fe43751cd2973fc0fd5b14126104122ca50483386c4085` |
| **Module Name** | `custodial_usdt` |
| **Network** | Aptos Testnet |
| **Language** | Move |

---

## 🧰 Prerequisites

- [Aptos CLI](https://aptos.dev/cli-tools/aptos-cli/install-cli/)
- Node funded with Testnet APT (use [Aptos Faucet](https://aptos.dev/network/faucet))
- Basic understanding of Move

---

## ⚙️ Project Setup

```bash
# 1. Create and initialize project
mkdir reset-token && cd reset-token
aptos move init --name sportsbook_platform

# 2. Fund your testnet account
# Visit https://aptos.dev/network/faucet?address=<YOUR_ADDRESS>

# 3. Edit Move.toml
````

```toml
[addresses]
sportsbook_platform = "0xfc26c5948f1865f748fe43751cd2973fc0fd5b14126104122ca50483386c4085"
```

---

## 🧩 Compile and Deploy

```bash
aptos move compile --named-addresses sportsbook_platform=0xfc26c5...4085
aptos move publish --profile admin --named-addresses sportsbook_platform=0xfc26c5...4085
```

Initialize (one time):

```bash
aptos move run --profile admin --function-id 0xfc26c5...4085::custodial_usdt::initialize
```

---

## 💵 Core Functions

### 1. Deposit

Add balance to any wallet (custodial credit).

```bash
aptos move run --profile admin \
--function-id 0xfc26c5...4085::custodial_usdt::deposit \
--args address:<TO_ADDRESS> u128:<AMOUNT>
```

---

### 2. Withdraw

Reduce caller’s balance.

```bash
aptos move run --profile admin \
--function-id 0xfc26c5...4085::custodial_usdt::withdraw \
--args u128:<AMOUNT>
```

---

### 3. Transfer

Move balance from caller to another user.

```bash
aptos move run --profile admin \
--function-id 0xfc26c5...4085::custodial_usdt::transfer \
--args address:<TO_ADDRESS> u128:<AMOUNT>
```

---

### 4. Balance View

Check wallet balance (view-only function):

```bash
aptos move view --profile admin \
--function-id 0xfc26c5...4085::custodial_usdt::balance_of \
--args address:<ADDR>
```

---

### 5. Admin Reset Controls

All require the **admin signer** (the deployer).

#### 🔹 Reset One Holder

```bash
aptos move run --profile admin \
--function-id 0xfc26c5...4085::custodial_usdt::admin_reset_one \
--args address:<ADDR> u128:<NEW_AMOUNT>
```

#### 🔹 Reset All

```bash
aptos move run --profile admin \
--function-id 0xfc26c5...4085::custodial_usdt::admin_reset_all \
--args u128:<NEW_AMOUNT>
```

#### 🔹 Reset Top K

```bash
aptos move run --profile admin \
--function-id 0xfc26c5...4085::custodial_usdt::admin_reset_top_k \
--args u64:<K> u128:<NEW_AMOUNT>
```

---

## 🔍 Example Flow

```bash
# Deposit 1000 USDT to self
aptos move run --profile admin \
--function-id 0xfc26c5...4085::custodial_usdt::deposit \
--args address:0xfc26c5...4085 u128:1000

# Check balance
aptos move view --profile admin \
--function-id 0xfc26c5...4085::custodial_usdt::balance_of \
--args address:0xfc26c5...4085

# Reset to 100
aptos move run --profile admin \
--function-id 0xfc26c5...4085::custodial_usdt::admin_reset_one \
--args address:0xfc26c5...4085 u128:100
```

---

## 🧠 Notes

* All balances live in one **global vector** — scalable up to a few thousand users.
* For production, replace with `aptos_std::table::Table<address, u128>` (for O(1) access).
* This module intentionally **centralizes control** for use-cases like sportsbooks, gaming wallets, or custodial exchanges.

---

## 🧾 Example Explorer Links

* **Module:**
  [Explorer ↗](https://explorer.aptoslabs.com/account/0xfc26c5948f1865f748fe43751cd2973fc0fd5b14126104122ca50483386c4085/modules?network=testnet)
* **Latest Init Tx:**
  [0x704d33...adf8 ↗](https://explorer.aptoslabs.com/txn/0x704d332a2739ed6895a4dc41ce516dd68164174b9523574087e50bd66d68adf8?network=testnet)
* **Last Publish:**
  [0x7fc2af...f4c ↗](https://explorer.aptoslabs.com/txn/0x7fc2afbda260119075355416e6fe5ad35ebb8e36bf2438f809979bbc817bcf4c?network=testnet)

---

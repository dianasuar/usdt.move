# 🪙 Custodial USDT — Aptos Move Token (Full Documentation)

A **centralized USDT-like token system** written in **Move** for the **Aptos blockchain**.  
This module allows a single admin (operator) to manage all user balances — making it perfect for **sportsbook platforms, gaming wallets, or custodial exchanges** where the app needs **full control** over deposits, withdrawals, and resets.

---

## 🧠 Overview

Unlike typical Aptos `CoinStore`-based tokens, this contract keeps **all balances inside the module itself** under a single `Balances` resource.

That means:
- 💼 No CoinStore per user  
- 🔐 Full control by admin  
- 🧾 Every holder tracked in on-chain vectors (`addrs`, `amts`)  

---

## ⚙️ Capabilities

| Feature | Description |
|----------|--------------|
| 💸 Deposit | Admin can add balance to any address |
| 💰 Withdraw | Users can deduct their own funds |
| 🔄 Transfer | Users can transfer to others |
| 🧹 Admin Reset One | Admin resets one user’s balance |
| 🌍 Admin Reset All | Admin resets all holders |
| 🏆 Admin Reset Top K | Admin resets only top K holders |
| 🔍 Balance Of | Anyone can check any wallet’s balance |

---

## 🧩 Module Info

| Field | Value |
|-------|-------|
| **Deployed Address** | `0xfc26c5948f1865f748fe43751cd2973fc0fd5b14126104122ca50483386c4085` |
| **Module Name** | `custodial_usdt` |
| **Network** | Aptos Testnet |
| **Language** | Move |
| **Author** | Abhishek Roushan ([KazarHQ](https://x.com/KazarHQ)) |

---

## 🧰 Requirements

- Install [Aptos CLI](https://aptos.dev/cli-tools/aptos-cli/install-cli/)
- Fund your wallet from the [Testnet Faucet](https://aptos.dev/network/faucet)
- Basic understanding of Move

---

## 🪜 1. Setup

```bash
mkdir reset-token && cd reset-token
aptos move init --name sportsbook_platform
```

Then edit `Move.toml`:

```toml
[addresses]
sportsbook_platform = "0xfc26c5948f1865f748fe43751cd2973fc0fd5b14126104122ca50483386c4085"
```

---

## ⚙️ 2. Compile & Publish

```bash
aptos move compile --named-addresses sportsbook_platform=0xfc26c5...4085
aptos move publish --profile admin --named-addresses sportsbook_platform=0xfc26c5...4085
```

Initialize (one time):

```bash
aptos move run --profile admin --function-id 0xfc26c5...4085::custodial_usdt::initialize
```

---

## 💵 3. Usage — Full Function Reference

### 🔹 Deposit

Add balance to any address.

```bash
aptos move run --profile admin --function-id 0xfc26c5...4085::custodial_usdt::deposit --args address:<TO_ADDRESS> u128:<AMOUNT>
```

### 🔹 Withdraw

Deduct funds from caller’s balance.

```bash
aptos move run --profile admin --function-id 0xfc26c5...4085::custodial_usdt::withdraw --args u128:<AMOUNT>
```

### 🔹 Transfer

Move tokens from one address to another.

```bash
aptos move run --profile admin --function-id 0xfc26c5...4085::custodial_usdt::transfer --args address:<TO_ADDRESS> u128:<AMOUNT>
```

### 🔹 Check Balance

Check current balance of an address.

```bash
aptos move view --profile admin --function-id 0xfc26c5...4085::custodial_usdt::balance_of --args address:<ADDR>
```

### 🔹 Admin Reset One

Reset one holder’s balance.

```bash
aptos move run --profile admin --function-id 0xfc26c5...4085::custodial_usdt::admin_reset_one --args address:<ADDR> u128:<NEW_AMOUNT>
```

### 🔹 Admin Reset All

Reset all holders’ balances to same value.

```bash
aptos move run --profile admin --function-id 0xfc26c5...4085::custodial_usdt::admin_reset_all --args u128:<NEW_AMOUNT>
```

### 🔹 Admin Reset Top K

Reset top K highest holders.

```bash
aptos move run --profile admin --function-id 0xfc26c5...4085::custodial_usdt::admin_reset_top_k --args u64:<K> u128:<NEW_AMOUNT>
```

---

## 🧾 Explorer Links (Testnet)

| Type | Link |
|------|------|
| **Module** | [View on Explorer](https://explorer.aptoslabs.com/account/0xfc26c5948f1865f748fe43751cd2973fc0fd5b14126104122ca50483386c4085/modules?network=testnet) |
| **Initialize Txn** | [0x704d33...adf8](https://explorer.aptoslabs.com/txn/0x704d332a2739ed6895a4dc41ce516dd68164174b9523574087e50bd66d68adf8?network=testnet) |
| **Last Publish Txn** | [0x7fc2af...f4c](https://explorer.aptoslabs.com/txn/0x7fc2afbda260119075355416e6fe5ad35ebb8e36bf2438f809979bbc817bcf4c?network=testnet) |

---

## 🧑‍💻 Author

**Abhishek Roushan**  
Founder & CEO — [Metakraft AI](https://metakraft.ai)  
X (Twitter): [@KazarHQ](https://x.com/KazarHQ)

---

## 🪪 License

MIT License © 2025  
Use freely for educational, experimental, or non-commercial custodial projects.

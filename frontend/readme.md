🪙 Custodial USDT — Admin Panel (Aptos Testnet)

This project lets you deploy and manage a simple USDT-like token on the Aptos Testnet.
It includes a Move smart contract and a small web UI to interact with it.

🧱 1. What’s Inside

Move Contract (custodial_usdt.move)
Stores balances, allows admin control, reset functions, and transfers.

Web UI (HTML + JS + CSS)
Lets you connect your Petra wallet and use all contract features easily.

⚙️ 2. Setup the Contract
Step 1 — Install Aptos CLI
npm install -g aptos

Step 2 — Create a folder and init
mkdir reset-token && cd reset-token
aptos init --profile admin --network testnet

Step 3 — Add your address to Move.toml
[addresses]
sportsbook_platform = "<YOUR_ADMIN_WALLET_ADDRESS>"

Step 4 — Add the contract file

Place your custodial_usdt.move inside the sources folder.

Step 5 — Compile & Publish
aptos move compile --named-addresses sportsbook_platform=<YOUR_ADMIN_WALLET_ADDRESS>
aptos move publish --profile admin --named-addresses sportsbook_platform=<YOUR_ADMIN_WALLET_ADDRESS>

Step 6 — Initialize
aptos move run --profile admin --function-id <YOUR_MODULE_ADDRESS>::custodial_usdt::initialize

🧪 3. Run the Frontend (Simple UI)
Option 1 — Quick (HTML only)

Put these 3 files together:

index.html

style.css

app.js

Right-click index.html → “Open with Live Server” (VS Code extension)

Browser opens at:

http://127.0.0.1:5500/

Option 2 — Manual

Just double-click index.html to open it in your browser.

🔗 4. Connect Your Wallet

Open Petra Wallet extension.

Switch Network → Testnet.

Click Connect Petra in your UI.

You’ll see your connected wallet address below.

🧮 5. Using the Functions
Function	Description	Who Can Use
deposit	Add balance to any wallet	Anyone
withdraw	Withdraw tokens from your wallet	Anyone
transfer	Send tokens to another address	Anyone
admin_reset_one	Reset one wallet’s balance to a new value	Admin only
admin_reset_all	Reset everyone’s balance to a new value	Admin only
admin_reset_top_k	Reset top-K biggest holders	Admin only
balance_of	View any wallet’s balance	Anyone
🧩 6. Example Inputs

Target Address: 0xabc123...

Amount: 1000

New Amount: 0

Top K: 10

🚫 Common Errors
Error	Meaning	Fix
Module not found	Using Mainnet instead of Testnet	Switch Petra to Testnet
Simulation error	Not admin address	Use the same wallet that deployed contract
Balance not found	Wallet never deposited before	Deposit first
✅ Example Flow

Connect Petra

Deposit → 10000

Check Balance → shows 10000

Admin → Reset One → set to 0

Check again → shows 0

📦 7. Re-Deploy with New Admin (Optional)

If you want a different wallet to become admin:

Update the address in Move.toml

Re-publish with the new address:

aptos move publish --profile admin --named-addresses sportsbook_platform=<NEW_ADMIN_ADDRESS>

🌐 8. Default Values (from demo)

Module Address:
0xfc26c5948f1865f748fe43751cd2973fc0fd5b14126104122ca50483386c4085

Fullnode:
https://fullnode.testnet.aptoslabs.com/v1

🧠 Notes

Always check Petra → Network: Testnet before running functions.

Admin functions work only for the deployer address.

Use Live Server or similar to test locally.

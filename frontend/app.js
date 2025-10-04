const FULLNODE = "https://fullnode.testnet.aptoslabs.com/v1";
const MODULE = "0xfc26c5948f1865f748fe43751cd2973fc0fd5b14126104122ca50483386c4085::custodial_usdt";

const connectBtn = document.getElementById("connect");
const log = document.getElementById("log");

let selfAddr = "";

connectBtn.onclick = async () => {
  const aptos = window.aptos;
  if (!aptos) return (log.textContent = "❌ Petra wallet not found!");

  try {
    const res = await aptos.connect();
    selfAddr = res.address;
    log.textContent = `✅ Connected: ${selfAddr}`;
  } catch (err) {
    log.textContent = "❌ Connection failed!";
  }
};

async function runFunction(fn, args = []) {
  const aptos = window.aptos;
  if (!aptos) return (log.textContent = "Wallet not found");

  try {
    const payload = {
      type: "entry_function_payload",
      function: `${MODULE}::${fn}`,
      type_arguments: [],
      arguments: args,
    };

    const tx = await aptos.signAndSubmitTransaction(payload);
    log.textContent = `✅ Submitted: ${tx.hash}`;
  } catch (e) {
    log.textContent = `❌ ${e.message || e}`;
  }
}

function $(id) {
  return document.getElementById(id).value;
}

document.getElementById("deposit").onclick = () =>
  runFunction("deposit", [ $("target"), $("amount") ]);

document.getElementById("withdraw").onclick = () =>
  runFunction("withdraw", [ $("amount") ]);

document.getElementById("transfer").onclick = () =>
  runFunction("transfer", [ $("target"), $("amount") ]);

document.getElementById("resetOne").onclick = () =>
  runFunction("admin_reset_one", [ $("target"), $("newAmount") ]);

document.getElementById("resetAll").onclick = () =>
  runFunction("admin_reset_all", [ $("newAmount") ]);

document.getElementById("resetTopK").onclick = () =>
  runFunction("admin_reset_top_k", [ $("kValue"), $("newAmount") ]);

document.getElementById("view").onclick = async () => {
  const body = {
    function: `${MODULE}::balance_of`,
    type_arguments: [],
    arguments: [ $("target") ],
  };

  try {
    const res = await fetch(`${FULLNODE}/view`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    });
    const data = await res.json();
    log.textContent = `ℹ️ Balance: ${data[0]}`;
  } catch (err) {
    log.textContent = `❌ ${err.message}`;
  }
};

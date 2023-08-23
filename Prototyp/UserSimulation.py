import time
from web3 import Web3

# Verbindung zum Sepolia-Netzwerk (Stellen Sie sicher, dass Sie die richtige RPC-URL haben)
w3 = Web3(Web3.HTTPProvider("https://YOUR_SEPOLIA_RPC_URL"))

# Ihr Konto und privater Schlüssel
account_address = "0xYourAccountAddress"
private_key = "YourPrivateKey"

# Adresse des Smart Contracts, mit dem Sie interagieren möchten
contract_address = "0xYourSmartContractAddress"
contract_abi = [...]  # ABI des Smart Contracts

contract = w3.eth.contract(address=contract_address, abi=contract_abi)

# Erstellen Sie die Transaktionsdaten
txn = contract.functions.YOUR_FUNCTION_NAME(ARGS_IF_ANY).buildTransaction(
    {
        "chainId": YOUR_SEPOLIA_CHAIN_ID,  # Chain ID für Sepolia
        "gas": 2000000,
        "gasPrice": w3.toWei("20", "gwei"),
        "nonce": w3.eth.getTransactionCount(account_address),
    }
)

# Signieren der Transaktion
signed_txn = w3.eth.account.signTransaction(txn, private_key)

# Zeitstempel erfassen
timestamp = time.time()

# Senden der Transaktion
txn_hash = w3.eth.sendRawTransaction(signed_txn.rawTransaction)
print(f"Transaktion von {account_address} gesendet mit Hash: {txn_hash.hex()}")
print(f"Transaktion abgeschickt um: {timestamp}")

# Optional: Warten auf die Bestätigung der Transaktion und Drucken der Dauer
receipt = w3.eth.waitForTransactionReceipt(txn_hash)
confirmation_time = time.time() - timestamp
print(f"Transaktion bestätigt nach {confirmation_time} Sekunden.")

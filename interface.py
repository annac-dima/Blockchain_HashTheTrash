from web3 import Web3
import json
from taxes_abi import *

ganache_url = 'HTTP://127.0.0.1:7545'
web3 = Web3(Web3.HTTPProvider(ganache_url))
web3.eth.defaultAccount = web3.eth.accounts[0] 

print(web3.isConnected())

# CONTRACT
contract_abi = json.loads(abi)
contract_bytecode = bytecode[0]

def deploy_contract(abi, bytecode):
    contract = web3.eth.contract(abi=abi, bytecode=bytecode)
    tx_hash = contract.constructor().transact()
    tx_receipt = web3.eth.waitForTransactionReceipt(tx_hash)
    return tx_receipt.contractAddress

contract_address = deploy_contract(abi=contract_abi, bytecode=contract_bytecode)

print(contract_address)



# MUNICIPALITY

from web3 import Web3
import json
from taxes_abi import *

ganache_url = 'HTTP://127.0.0.1:7545'
w3 = Web3(Web3.HTTPProvider(ganache_url))
w3.eth.defaultAccount = w3.eth.accounts[0] 

print(web3.isConnected())

# Contract abi
taxes_abi = json.loads(abi)

address = '0x819b95284Eb64Ef8F8ea426b108379555dD81C3e'
taxes_contract = w3.eth.contract(address=address, abi=taxes_abi)


# MUNICIPALITY

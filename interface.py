from web3 import Web3
import json
from taxes_abi import *

ganache_url = 'HTTP://127.0.0.1:7545'

web3 = Web3(Web3.HTTPProvider(ganache_url))

print(web3.isConnected())

taxes_abi = json.loads(abi)

# municipality account
web3.eth.defaultAccount = web3.eth.accounts[0] 

taxes_contract = web3.eth.contract(address='0x819b95284Eb64Ef8F8ea426b108379555dD81C3e', abi=taxes_abi)

taxes

import json
import random
import pandas as pd
import time
from web3 import Web3
from abi_bytecode import abi, bytecode # saved externally as .py

# Connecting to ganache through opened up PORT
ganache_url = 'HTTP://127.0.0.1:7545'      #change here if different
web3 = Web3(Web3.HTTPProvider(ganache_url))
web3.isConnected()
    
deployed_ctr = web3.eth.contract(address=tx_receipt.contractAddress, abi=_abi) # contract


def get_past_logs(filter_list, poll_interval):
    """
    Iterates over every filter built and extracts logs from the block specified in the filter to the 'latest'
    
    inputs
    ---------------
     filter_list : filters created
    
    returns
    ---------------
     list containing every event attribute generated from the 'emit' on the contract
    """
    events = []
    while True:
        for event_filter in filter_list:
            for e in event_filter.get_new_entries(): # get_new_entry() to check only last block
                
                # e is a nested dictionary, like this we bring all elements on the same level
                args = dict(e['args'])
                args.update(dict(e))
                del args['args'] # brought one level above, delete the nest
                # args.pop('args', None) # could delete like this too
                
                events.append(args)
        time.sleep(poll_interval)    
    return events

# Compiled abi and bytecode of trash.sol which inherits from citizenz.sol (and Ownable, safemath etc)
abiRemix = json.loads(abi)         # turned to string after copy to clipboard from Remix
bytecodeRemix = bytecode['object'] # it is a dictionary (as copy to clipboard form remix), we use the object for web3 deployment

contract = deploy_contract(deployer=web3.eth.accounts[0], _abi=abiRemix, _bytecode=bytecodeRemix)

pickedUp_filter = [contract.events.PickedUp.createFilter(fromBlock='latest')]

def log_loop(event_filter, poll_interval):
    while True:
        for event in event_filter.get_new_entries():
            handle_event(event)
        time.sleep(poll_interval)

def main():
    block_filter = w3.eth.filter('latest')
    log_loop(block_filter, 2)







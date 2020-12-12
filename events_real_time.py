import json
import pandas as pd
import time
from web3 import Web3
from contracts.abi_bytecode import abi # saved externally as .py

# THINGS WE NEED!!  
# Connecting to ganache through opened up PORT
ganache_url = 'HTTP://127.0.0.1:7545'      #change here if different
web3 = Web3(Web3.HTTPProvider(ganache_url))
web3.isConnected()
abi = json.loads(abi)     # To le the log filter understand the logs
df = pd.DataFrame()       # Empty only the first time

def connect_to_contract():
    """
    Connect to the contract to retrieve event logs
    """

    with open('data/ctr_addr.txt', 'r') as f:
        address = f.read()
    print(f'Connected to ctr : {address}')

    ctr = web3.eth.contract(address = address, abi = abi)
    return ctr


def create_filters(contract):
    """
    Create the filters to look for the selected events
    """

    f1 = contract.events.PickedUp.createFilter(fromBlock = 'latest')
    f2 = contract.events.Deposited.createFilter(fromBlock = 'latest')
    f3 = contract.events.Received.createFilter(fromBlock = 'latest')

    return [f1, f2, f3]


def handle_dataframe(df, event):
    """
    Update and save event logs in an external file
    """
    
    df = pd.read_csv('data/events_log.csv')
    if not isinstance(event, dict):
        raise Exception('The event must be passed in dictionary form')
    df = df.append(event, ignore_index=True)
    df.to_csv('data/events_log.csv', index=False)


def handle_event(e):
    """
    Get the event logs from the latest block
    """

    args = dict(e['args'])
    args.update(dict(e))
    del args['args']
    
    return args


def log_loop(df, filter_list, poll_interval):
    """
    Fetch events in real time
    """

    while True:
        for event_filter in filter_list:
            for e in event_filter.get_new_entries():
                print(e['event'])
                ev = handle_event(e)
                handle_dataframe(df, ev)
                

        time.sleep(poll_interval)

def main():
    contract = connect_to_contract()
    filter_list = create_filters(contract=contract)
    log_loop(df=df, filter_list=filter_list, poll_interval=2)


if __name__ == '__main__':
    main()






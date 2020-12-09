# FinTech 20598 - Final Group Project - Group 1
Implementation of a Blockchain for Rubbish and waste collection. 


### To implement in Python: 
1. AGENTS CREATION 
  - Creation of agents (Done) - *EXCEL* 

2. TARI 
  - Municipality computes TARI for all citizens: `function TariAmount(address _address)`
  - All citizens pay TARI (for loop - therefore they all pay the same day): `function payTari() external payable onlyCitizen`

3. TRASH 
  - Pick up trahs bags: `function pick(address _citizen, uint _wasteWeight, uint _random)` - *EXCEL*
  - Drop bags at disposal station: `function drop(address _disposalStation, int _latitudeTruck, int _longitudeTruck)` - *EXCEL*

  - Station last check: `function received(bool _waste, address _truck, uint _weight)` - *EXCEL?*

4. REFUND
  - Municipality computes payout for all citizens (not saved in any variable) and pays: `function computePayout(address payable _citizen)`, `function givePayout(address payable _citizen)`


## Improvements: 
1. `enum WasteType {Nonrecyclable, Paper, Plastic, Organic, Glass}`
2. Fiscal code instead of name 
3. Latitude and Longitude precision (how many decimals?) 

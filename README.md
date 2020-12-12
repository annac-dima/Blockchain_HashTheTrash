# Rubbish Blockchain 
Implementation of a Blockchain for Rubbish and waste collection. The project aims at building a blockchain system to be used by municipalities to track the waste produced by citizens. This would allow to monitor the amount as well as nature of the rubbish produced te record waste production. Moreover, all the rubbish produced is tracked from the citizen to the disposal station to avoid illegal dumping. Citizens are incentivized to recycle and to produce less waste as they receive a tax reduction according to their waste behaviour during the year. 

## How to use this repo 
1. Install `requirements`:
```shell script
pip install -r requirements.txt
```
2. Run `HashTheTrash.ipynb`: to simulate the creation and collection of waste. To work correctly, this file needs:
  * 10 ETH accounts: there're the Municipality, 5 citizens, 1 non-recyclable truck and 1 recyclable one, 1 non-recyclable disposal station and 1 recyclable one.
  * `example_data.xlsx`: file containing necessary data to perform a simulation. Stored in `data` folder. 
  * 2 Smart Contracts: they and their ABI code are stored in `contracts` folder. 


## Trash Chain 
### 1. AGENTS CREATION 
  - Creation of agents - *EXCEL = agents_data.xlsx* 

### 2. TARI 
  - Municipality computes TARI for all citizens: `function TariAmount(address _address)`
  - All citizens pay TARI (for loop - therefore they all pay the same day): `function payTari() external payable onlyCitizen`

### 3. TRASH 
  - Pick up trahs bags: `function pick(address _citizen, uint _wasteWeight, uint _random)` - *EXCEL = bags_data.xlsx*   
```diff
- _random: deve essere generato in python e fatta una nuova colonna 
- _citizen è l'address e ce lo ricaviamo dal nome che è nel'excel perchè se io uso i miei address 
- direttamente nell'excel poi dovremmo cambiarli ogni volta che usiamo un ganache diverso 
```
  - Drop bags at disposal station: `function drop(address _disposalStation, int _latitudeTruck, int _longitudeTruck)` - *EXCEL = gps_data.xlsx*  
```diff
- _disposalStation è l'address e ce lo ricaviamo dal nome che è nel'excel perchè se io uso i miei address 
- direttamente nell'excel poi dovremmo cambiarli ogni volta 
``` 
  - Station last check: `function received(bool _waste, address _truck, uint _weight)` - *EXCEL?*

### 4. REFUND
  - Municipality computes payout for all citizens (not saved in any variable) and pays: `function computePayout(address payable _citizen)`, `function givePayout(address payable _citizen)`


## Improvements: 
1. `enum WasteType {Nonrecyclable, Paper, Plastic, Organic, Glass}`
2. Fiscal code instead of name 
3. Latitude and Longitude precision (how many decimals?) 

## Authors: 
 - Francesca Bianchessi 
 - Ilaria Bolla
 - Alessandro Botti
 - Davide Castellini
 - Bianca Cattadori
 - Anna Chiara Di Marco 
 - Priamo Puschiasis 

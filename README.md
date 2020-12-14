# Rubbish Blockchain 
This aim of this project is to apply the blockchain technology to improve waste management processes in developed countries. The employment of the blockchain would result in the creation of a single decentralized platform which allows real-time tracking of waste through the various steps of the recycling process. It would thus be possible to track the amount of waste collected, who collected it, and where it is being moved for recycling or disposal. The increased transparency resulting from this would stop or at least reduce the number of ecological crimes related to waste treatment. Moreover, the blockchain technology could also be used to incentivize people to correctly dispose waste. In particular, smart contracts could be used to reward people with some tax reductions on the basis of their recycling behavior throughout the year. 

In this GitHub repository, you can find all the files and data needed to perform a simulation of the “Rubbish Blockchain” described above. In particular, for the purposes of the simulation, we consider a small municipality comprising of five people, two trucks, and two disposal stations, for a total of ten actors. In this way, it is possible to use all the ten Ethereum accounts provided by Ganache. Moreover, for simplicity, the garbage produced by the five citizens is simply classified as recyclable or non-recyclable, and waste collection is performed by trucks on the basis of a door-to-door system.

The two contracts stored in the folder “contract”, i.e. agents.sol and trashlife.sol, are the contracts that the Municipality would have to deploy at the beginning of each year, and then destroy at the end of each year. The Jupyter notebook “HashTheTrash” provides a clear and straightforward simulation of the functioning of these two contracts.
 

## How to use this repo 
1. Install `requirements`:
```shell script
pip install -r requirements.txt
```
2. If not already downloaded, download Ganache at the link https://www.trufflesuite.com/ganache
3. Run `HashTheTrash.ipynb` to simulate the creation and collection of waste. To work correctly, this file needs:
   * 10 ETH accounts: there're the Municipality, 5 citizens, 1 non-recyclable truck and 1 recyclable one, 1 non-recyclable disposal station and 1 recyclable one.
   * `example_data.xlsx`: file containing necessary data to perform a simulation. Stored in `data` folder. 
   * Two Smart Contracts: stored in `contracts` folder with their ABI code.    


## Trash Chain 
### 1. AGENTS CREATION 
  - Creation of agents - *EXCEL SHEET = agents_data.xlsx* 

### 2. TARI 
  - Municipality computes TARI for all citizens: `function TariAmount(address _address)`
  - All citizens pay TARI (for loop - therefore they all pay the same day): `function payTari() external payable onlyCitizen`

### 3. TRASH 
  - Pick up trahs bags: `function pick(address _citizen, uint _wasteWeight, uint _random)` - *EXCEL SHEET = bags_data.xlsx*   

  - Drop bags at disposal station: `function drop(address _disposalStation, int _latitudeTruck, int _longitudeTruck)` - *EXCEL SHEET = gps_data.xlsx*  

  - Station last check: `function received(bool _waste, address _truck, uint _weight)` - *EXCEL SHEET = stations_data.xlsx*

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

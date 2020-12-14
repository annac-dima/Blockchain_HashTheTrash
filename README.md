# HASH the TRASH - A Rubbish Blockchain Application
HashTheTrash is a blockchain application for real-time waste tracking, based on two Ethereum Smart Contracts. The aim of this project is to increase the transparency along all the steps involved in the trash chain in order to improve waste management processes in developed countries, such as Italy, taken as reference for the simulation. 

#### Why a rubbish blockchain?
Through the blockchain technology it would be possible to track the amount of waste collected, who collected it, and where it is being moved for recycling or disposal in a truly transparent way, leading to stopping, or at least reducing, the number of ecological crimes related to waste treatment. Moreover, this waste tracing enables the defintion of a "trash footprint" of each citizen, that could be used to incentivize people to correctly dispose waste. In particular, tracking each trash bag from its production to its disposal, would make it possible to reward citizens with some tax reductions on the basis of their recycling behavior throughout the year. 

#### Why blockchain? 
The need of a public and permissionless blockchain, such as the Ethereum one, results from the multitude of actors involved in the garbage chain, whose interests are never unified and may be malicious. Up to now, waste management supervision remained controlled by the public sector and monitoring tools to check how public authorities manage the garbage chain are few. Therefore, HashTheTrash may solve this lack of measures to control controllers and ensure public sector's transparency and accountability. 

#### Simulation 
In this GitHub repository, all the files and data needed to perform a simulation of this waste tracking system are provided. In particular, for the purpose of the simulation, it has been considered a small municipality comprising of five citizens, two garbage trucks, and two disposal stations, for a total of ten actors. Moreover, for simplicity, the garbage produced by the five citizens is simply classified as recyclable or non-recyclable, and waste collection is performed by trucks on the basis of a door-to-door system.

The whole application works with the deployment of two smart contracts, stored in the `contract` folder. The idea is that each Municipality would have to deploy at the beginning of each year both these contracts, and then destroy them at the end of each year. The Jupyter notebook `HashTheTrash.ipynb` provides a clear and straightforward simulation of the functioning of these two contracts.
 
## How to use this repo 
1. Install `requirements`:
```shell script
pip install -r requirements.txt
```
2. If not already downloaded, download [Ganache](https://www.trufflesuite.com/ganache), a developer tool that provides a personal Ethereum blockchain with 10 accounts to test Solidity contracts. 
3. Run `HashTheTrash.ipynb` to simulate the creation and collection of waste. To work correctly, this file needs:
   * 10 ETH accounts: there're the Municipality, 5 citizens, 1 non-recyclable truck and 1 recyclable one, 1 non-recyclable disposal station and 1 recyclable one. They are the 10 accounts provided directly by Ganache.
   * `example_data.xlsx`: excel file containing the necessary data to perform a simulation. Stored in `data` folder. 
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
For a real-life implementation of the Rubbish Blockchain, some improvements would be very useful:
-	For the unique identification of citizens, we could substitute their full name in the struct “Citizen” with their fiscal code.
-	Instead of simply classifying waste as recyclable or non-recyclable, we could be more specific and distinguish also the various types of recyclable waste, e.g. plastic, paper, glass, etc. This can be done pretty easily by substituting the Boolean “waste” (equal to true when waste is recyclable) with something on the line of `enum WasteType {Nonrecyclable, Paper, Plastic, Organic, Glass}`. The rest of the code would then need to be adapted to this small change.
-	The code could also be adapted to be compatible with waste collection systems that differ from the simple door-to-door collection system.


## Privacy considerations:
For a real-life implementation of the Rubbish Blockchain, some privacy considerations could also be raised. The transparency of the blockchain has undoubtedly great advantages, since it allows to track waste through the various steps of the waste management process and thus reduces the number of ecological crimes related to waste treatment. However, this same transparency could also cause some problems. For example, assume that a malicious individual X was able to associate an Ethereum address to a specific citizen Y. By observing the transactions recorded on the blockchain, X could infer whether Y was on holiday, or in general away from his house, and burgle his house. Indeed, if for a period of time no transactions were recorded about trash bags generated by Y, X could assume that Y was not at home and take advantage of this situation. Therefore, if someone wanted to implement the Rubbish Blockchain in real life, it would be advisable to think further about the potential privacy issues that could arise from this. 


## Authors: 
 - Francesca Bianchessi 
 - Ilaria Bolla
 - Alessandro Botti
 - Davide Castellini
 - Bianca Cattadori
 - Anna Chiara Di Marco 
 - Priamo Puschiasis 

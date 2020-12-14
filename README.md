# Rubbish Blockchain 
The aim of this project is to apply the blockchain technology to improve waste management processes in developed countries. The employment of a blockchain would result in the creation of a single decentralized platform which allows real-time tracking of waste through the various steps of the recycling process. It would thus be possible to track the amount of waste collected, who collected it, and where it is being moved for recycling or disposal. The increased transparency resulting from this would stop or at least reduce the number of ecological crimes related to waste treatment. Moreover, the blockchain technology could also be used to incentivize people to correctly dispose waste. In particular, smart contracts could be used to reward people with some tax reductions on the basis of their recycling behavior throughout the year. 

In this GitHub repository, you can find all the files and data needed to perform a simulation of the *Rubbish Blockchain* described above. In particular, for the purposes of the simulation, we consider a small municipality comprising of five people, two trucks, and two disposal stations, for a total of ten actors. In this way, it is possible to use all the ten Ethereum accounts provided by Ganache. Moreover, for simplicity, the garbage produced by the five citizens is simply classified as recyclable or non-recyclable, and waste collection is performed by trucks on the basis of a door-to-door system.

The two contracts stored in the folder `contract`, i.e. agents.sol and trashlife.sol, are the contracts that the Municipality would have to deploy at the beginning of each year, and then destroy at the end of each year. The Jupyter notebook `HashTheTrash` provides a clear and straightforward simulation of the functioning of these two contracts.
 

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

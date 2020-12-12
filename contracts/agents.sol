pragma solidity ^0.6.0; 

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

// The Agents Contract must be deployed only by the Municipality to create and delete citizens, trucks and disposal stations

contract Agents is Ownable {
   
    using SafeMath for uint; 
    using SafeMath for int;
    
    uint start; // Define a variable that each year is set equal to 1st January
    bool alreadySet; // Define a varible equal to false by default, so that the "setBeginningYear" function cannot be invoked twice in a year
    
    // Define a function the Municipality calls at the beginning of each year to set start = 1st January
    function setBeginningYear () public onlyOwner returns (uint) {
        require(alreadySet == false, "The function has already been called");
        start = now;
        alreadySet = true;
        return start;
    }
    
    // Define a function to check which is the starting day of the year, to check that the Municipality has correctly set it
    function showStartTime () public view returns (uint) {return start;}
    
    // Define a struct to store relavant data about each citizen
    struct Citizen {
        string name; // Full name
        uint family; // Number of household members
        uint house; // Size of the house (mq)
        uint weight; // Total weight of waste produced last year
        
        uint TARI; // Amount of TARI due (initialized as 0 and computed by the Municipality) 
        uint totalRecyclableWaste; // Total amount of recyclable waste produced during the year (in kg)
        uint totalNonRecyclableWaste; // Total amount of non-recyclable waste produced during the year (in kg)
        bool payTARI; // True if a specific citizen has already paid the TARI, False otherwise
        bool active; // Boolean to guarantee the existence and uniqueness of the citizen (True once this struct is created)
    }
    
    // Define a struct to store relavant data about each truck
    struct Truck {
        uint truck_number; // Truck Number (given when created by the Municipality)
        uint weight; // Total weight the truck carries before dumping its cargo at a disposal station
        bool waste; // Type of waste (recyclable or not) that the truck is carrying 
        bool active; // Boolean to guarantee the existence and uniqueness of the truck (True once this struct is created)
    }
    
    // Define a struct to store relavant data about each disposal station
    struct Station {
        uint station_number; // Station Number 
        uint weight; // Cumulative sum of the weight of trash accumulated at the station during the year 
        int latitude; // Gps coordinates of the station (latitude)
        int longitude; // Gps coordinates of the station (longitude)
        bool waste; // Type of waste (recyclable or not) that the station disposes 
        bool active; // Boolean to guarantee the existence and uniqueness of the station (True once this struct is created)
    }
    
    // Define 3 mappings so that each truck, citizen and station is uniquely associated to an Ethereum address
    mapping(address => Truck) public trucks; 
    mapping(address => Citizen) public citizens;
    mapping(address => Station) public stations; 

    // Define an event to signal to the blockchain that a citizen has been "created" (has been added to the mapping "citizens")
    uint citizenCounter; 
    event CitizenBorn(address payable indexed _citizen, bool payTARI);
    
    // Define an event to signal to the blockchain that a station has been "created" (has been added to the mapping "stations")
    uint stationCounter; 
    uint stationNumber; 
    event StationBorn(address indexed _station, int _long, int _lat);
    
    // Define an event to signal to the blockchain that a truck has been "created" (has been added to the mapping "trucks")
    uint truckCounter; 
    uint truckNumber;
    event TruckBorn(address indexed _truck);
    
    // Define functions to check the total number of citizens, trucks and stations 
    function numberT() public view returns (uint) {return truckCounter;}
    function numberC() public view returns (uint) {return citizenCounter;}
    function numberS() public view returns (uint) {return stationCounter;}
    
    // All the following functions can be invoked only by the owner of this contract, that is the Municipality 
    
    // Define a function to add a new citizen to the system, and emit the respective event 
    function createCitizen(address payable _address, string memory _name, 
    uint _family, uint _house, uint _w) public onlyOwner {
        require(citizens[_address].active == false); // Make sure the citizen is not already present in the "citizens" mapping
        citizenCounter++; // Increase the total counter of citizens present in the mapping
        
        // Create the struct: TARI due, non-rec. and rec. waste are set to 0; payTARI is set to False and the citizen is declared as active
        citizens[_address] = Citizen(
            _name,
            _family,
            _house,
            _w,
            0,
            0,
            0,
            false,
            true);
        emit CitizenBorn(_address, false);
        
    }
    
    // Define a function to remove a specific citizen from the system
    function deleteCitizen(address _address) public onlyOwner {
        require(citizens[_address].active == true); // Make sure the citizen exists in the "citizens" mapping
        delete citizens[_address]; // Remove the address from the mapping
        citizenCounter--; // Decrease the total citizens counter
    }
    
    // Define a function to add a new truck to the system, and emit the respective event 
    function createTruck(address _address, bool _recycle) public onlyOwner {
        require(trucks[_address].active == false); // Make sure the truck is not already present in the "trucks" mapping
        truckCounter++; // Increase the total counter of trucks present in the mapping
        truckNumber++;
        trucks[_address] = Truck(truckNumber, 0, _recycle, true); // Create the Truck struct and add it to the mapping
        emit TruckBorn(_address);
    }
    
    // Define a function to remove a specific truck from the system
    function deleteTruck(address _address) public onlyOwner {
        require(trucks[_address].active == true); // Make sure the truck exists in the "trucks" mapping
        delete trucks[_address]; // Remove the address from the mapping
        truckCounter--; // Decrease the total trucks counter
    }
    
    // Define a function to add a new station to the system, and emit the respective event 
    function createStation(address _address, bool _recycle, int _lat, int _long) public onlyOwner {
        require(stations[_address].active == false); // Make sure the station is not already present in the "stations" mapping
        stationCounter++; // Increase the total counter of stations present in the mapping
        stationNumber++;
        stations[_address] = Station(stationNumber, 0, _lat, _long, _recycle, true); // Create the Station struct and add it to the mapping
        emit StationBorn(_address, _long, _lat);
    }
    
    // Define a function to remove a specific station from the system
    function deleteStation(address _address) public onlyOwner {
        require(stations[_address].active == true); // Make sure the station exists in the "stations" mapping
        delete stations[_address]; // Remove the address from the mapping
        stationCounter--; // Decrease the total stations counter
    }
    
}

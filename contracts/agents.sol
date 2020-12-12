pragma solidity ^0.6.0; 

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract Agents is Ownable {
    /* Agents Contracts chas to be deployed by the municipaility. It defines the elements and functions to define the different agents involved in the system ecosystem and 
    store relevant information about them. 
    Only the municipality is allowed to register or delete new agents. */
    
    using SafeMath for uint; 
    using SafeMath for int;
    
    // Define a variable that is going to be set equal to 1st January of each year
    uint start; 
    // Define a varible alreadySet, equal to false by default, so that the following function, "setBeginningYear", is not called twice
    bool alreadySet;
    
    /* Define a function that the municipality (owner of this contract) has to call at the beginning of each year. This is to set the 
    varibale start = 1st January, and has to be the first function called by the municipality each year. */
    function setBeginningYear () public onlyOwner returns (uint) {
        require(alreadySet == false, "The function has already been called");
        
        start = now;
        alreadySet = true;
        return start;
    }
    
    // The following function is just to check that everything has worked correctly
    function showStartTime () public view returns (uint) {
        return start;
    }
    
    /* Define a struct for each citizen so that the municipality can access relevant information about them and also check their fiscal 
    situations. The struct is used to store data about each citizen. */
    struct Citizen {
        string name; // Full name
        uint family; // Number of family members
        uint house; // Size of the house
        uint weight; // Total weight of trash produced last year
        
        uint TARI; // Amount of TARI due
        uint totalRecyclableWaste; // Total amount of recyclable waste produced during the year 
        uint totalNonRecyclableWaste; // Total amount of non-recyclable waste produced during the year 
        bool payTARI; // boolean to check whether a specific citizen has already paid the TARI
        bool active; // boolean to guarantee the existence and uniqueness of the citizen. 
    }
    
    // Define a struct to store relavant information about each truck
    struct Truck {
        uint truck_number; // Truck id
        uint weight; // Total weight that the truck is carrying
        bool waste; // Type of waste (recyclable or not) that the truck is carrying 
        bool active; // boolean to guarantee the existence and uniqueness of the truck
    }
    
    // Define a struct to store relavant information about each station
    struct Station {
        uint station_number; // Station id
        uint weight; // Cumulative sum of the weight of trash accumulated at the station during the year 
        int latitude; // Gps coordinates of the station (latitude)
        int longitude; // Gps coordinates of the station (longitude)
        bool waste; // Type of waste that the station disposes 
        bool active; // boolean to guarantee the existence and uniqueness of the station
    }
    
    // Define some mappings so that each truck, citizen and station is uniquely associated to an Ethereum address
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
    
    // Define some functions to check the total number of citizens, trucks and stations 
    function numberT() public view returns (uint) {return truckCounter;}
    function numberC() public view returns (uint) {return citizenCounter;}
    function numberS() public view returns (uint) {return stationCounter;}
    
    // Following functions use onlyOwner modifier. Therefore only the owner of the contract, which is the municipality taht first deployed the contract, can call them. 

    // Define a function to add a new citizen to the system, and emit the respective event 
    function createCitizen(address payable _address, string memory _name, 
    uint _family, uint _house, uint _w) public onlyOwner {
        require(citizens[_address].active == false);
        citizenCounter++; 
        
        // initilize the citizen struct
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
    
    /* Define a function to remove a specific citizen from the system. In pratice, the citizen in question is removed from the 
    mapping "citizens". */
    function deleteCitizen(address _address) public onlyOwner {
        require(citizens[_address].active == true);
        delete citizens[_address];
        citizenCounter--;
    }
    
    // Define a function to add a new truck to the system, and emit the respective event 
    function createTruck(address _address, bool _recycle) public onlyOwner {
        require(trucks[_address].active == false);
        truckCounter++;
        truckNumber++;
        trucks[_address] = Truck(truckNumber, 0, _recycle, true);
        emit TruckBorn(_address);
    }
    
    /* Define a function to remove a specific truck from the system. In pratice, the truck in question is removed from the 
    mapping "trucks" */
    function deleteTruck(address _address) public onlyOwner {
        require(trucks[_address].active == true);
        delete trucks[_address];
        truckCounter--;
    }
    
    // Define a function to add a new station to the system, and emit the respective event 
    function createStation(address _address, bool _recycle, int _lat, int _long) public onlyOwner {
        require(stations[_address].active == false);
        stationCounter++;
        stationNumber++;
        stations[_address] = Station(stationNumber, 0, _lat, _long, _recycle, true);
        emit StationBorn(_address, _long, _lat);
    }
    
    /* Define a function to remove a specific station from the system. In pratice, the station in question is removed from the 
    mapping "stations" */
    function deleteStation(address _address) public onlyOwner {
        require(stations[_address].active == true);
        delete stations[_address];
        stationCounter--;
    }
    
}

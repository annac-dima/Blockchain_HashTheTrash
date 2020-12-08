pragma solidity ^0.6.0; 

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract Agents is Ownable {
    
    using SafeMath for uint; 
    using SafeMath for int;
    using SafeMath for uint256;
    
    struct Citizen {
        address payable citizenAddress; 
        string name; 
        uint family; 
        uint house; 
        uint weight;
        uint TARI; 
    
        uint totalRecyclableWaste; 
        uint totalNonRecyclableWaste;
        bool payTARI;
        bool active;
    }
    
    struct Truck {
        uint truck_number;
        uint weight;
        bool waste;
        bool active; 
    }
    
    struct Station {
        uint station_number; 
        uint weight;
        int longitude; 
        int latitude; 
        bool waste; 
        bool active; 
    }
    
    struct Municipality {
        uint municipality_number; 
        bool active;
    }
    
    mapping(address => Municipality) public municipalities;
    mapping(address => Truck) public trucks; 
    mapping(address => Citizen) public citizens;
    mapping(address => Station) public stations; 
    
    uint municipalityCounter; 
    event MunicipalityBorn(address payable indexed _municipality);
    
    uint citizenCounter; 
    event CitizenBorn(address payable indexed _citizen, bool payTARI);
    
    uint stationCounter; 
    uint stationNumber; 
    event StationBorn(address indexed _station, int _long, int _lat);
    
    uint truckCounter; 
    uint truckNumber;
    event TruckBorn(address indexed _truck);
    
    function numberT() public view returns (uint) {return truckCounter;}
    function numberC() public view returns (uint) {return citizenCounter;}
    function numberS() public view returns (uint) {return stationCounter;}
    function numberM() public view returns (uint) {return municipalityCounter;}
    
    function createCitizen(address payable _address, string memory _name, 
    uint _family, uint _house, uint _w) public onlyOwner {
        require(citizens[_address].active == false);
        citizenCounter++; 
        
        citizens[_address] = Citizen(
            _address, 
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
    
    function deleteCitizen(address _address) public onlyOwner {
        require(citizens[_address].active == true);
        delete citizens[_address];
        citizenCounter--;
    }
    
    function createTruck(address _address, bool _recycle) public onlyOwner {
        require(trucks[_address].active == false);
        truckCounter++;
        truckNumber++;
        trucks[_address] = Truck(truckNumber, 0, _recycle, true);
        emit TruckBorn(_address);
    }
    
    function deleteTruck(address _address) public onlyOwner {
        require(trucks[_address].active == true);
        delete trucks[_address];
        truckCounter--;
    }
    
    function createStation(address _address, bool _recycle, int _long, int _lat) public onlyOwner {
        require(stations[_address].active == false);
        stationCounter++;
        stationNumber++;
        //int long = _long.div(10);
        //int lat = _lat.div(10);
        stations[_address] = Station(stationNumber, 0, _long, _lat, _recycle, true);
        emit StationBorn(_address, _long, _lat);
    }
    
    function deleteStation(address _address) public onlyOwner {
        require(stations[_address].active == true);
        delete stations[_address];
        stationCounter--;
    }
    
    function createMunicipality(address payable _address) public onlyOwner {
        require(municipalities[_address].active == false);
        municipalityCounter++;
        municipalities[_address] = Municipality(municipalityCounter, true);
        emit MunicipalityBorn(_address);
    }
    
    function deleteMunicipality(address _address) public onlyOwner {
        require(municipalities[_address].active == true);
        delete municipalities[_address];
        municipalityCounter--;
    }
    
}
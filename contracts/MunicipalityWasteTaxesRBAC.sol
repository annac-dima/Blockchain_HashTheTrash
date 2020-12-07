pragma solidity 0.6.0;

// import Ownable.sol
import "./Ownable.sol";
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
// import "./github/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

// import SafeMath.sol
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
// import "./github/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";
import "./SafeMath.sol";

//import Roles.sol
// import "https://github.com/hiddentao/openzeppelin-solidity/blob/master/contracts/access/Roles.sol";
import "./Roles.sol";


contract MunicipalityWasteTaxesRBAC is Ownable {
    
    // to be able to use the functions defined inside the Roles and SafeMath libraries we need to use the `using` keyword
    // use SafemMath for uints and integers 
    using SafeMath for uint;
    using SafeMath for int;
    
    // use Roles for Role. Roles is the name of the library while Role is the name of the struct defined there
    using Roles for Roles.Role;
    
    // define the roles we will use in this contract. We make them private so that outsiders cannot easily read their content
    // create a role for citizens
    Roles.Role private citizenRole;
    // create a role for garbage collectors
    Roles.Role private garbageCollectorRole;
    // create a role for the person managing the municipality. This role will be the equivalent of the admin
    Roles.Role private municipalityManagers;
    
    // add a contructor that will allow us to set the initial admin, otherwise we will not be able to assign any other role 
    // the constructor will be called only once when the contract is deployed by the municipality
    constructor() public {
        // give the deployer of this contract the role of municipality manager
        // add() is a function defined inside the Roles library and can be used on instances of Roles.Role
        municipalityManagers.add(msg.sender);
    }
    
    // create a function to give some addresses the role of citizens. This function will take an ethereum address as input
    // this function will be private, so it will be possible to call it only inside this contract
    function _addCitizenRole(address _newCitizen) private {
        citizenRole.add(_newCitizen);
    }
    
    // create a function to give some specific addresses the role of garbage collectors. This function will take an ethereum address as input
    // only addresses having the municipalityManagers role will be able to call this function
    function _addGarbageCollectorRole(address _newGarbageCollector) private onlyMunicipalityManager() {
        garbageCollectorRole.add(_newGarbageCollector);
    }
    
    // initially we can assume that the municipality is managed by a single address but this may not always be the case so
    // we also create a function to give some other addresses the role of municipality.
    // This function will take again an ethereum address as input
    // only addresses already having the municipalityRole will be able to call this function
    function _addMunicipalityManager(address _newMunicipalityManager) external onlyMunicipalityManager() {
        municipalityManagers.add(_newMunicipalityManager);
    }
    
    // create a function to remove an address from the citizenRole
    // only addresses having the municipalityManagers role will be able to call this function
    function _removeCitizenRole(address _oldCitizen) external onlyMunicipalityManager() {
        // remove() is a function defined inside the Roles library and can be used on instances of Roles.Role
        citizenRole.remove(_oldCitizen);
    } 
    
    // create a function to remove an address from the garbageCollectorRole
    // only addresses having the municipalityManagers role will be able to call this function
    function _removeGarbageCollectorRole(address _oldGarbageCollector) external onlyMunicipalityManager() {
        garbageCollectorRole.remove(_oldGarbageCollector);
    } 
    
    // create a function to remove an address from the municipalityManagers role
    // only addresses already having the municipalityManagers role will be able to call this function
    function _removeMunicipalityManagers(address _oldMunicipalityManagers) external onlyMunicipalityManager() {
        municipalityManagers.remove(_oldMunicipalityManagers);
    } 
    
    // define a modifier than makes sure that only addresses with the municipalityManagers role can call some sensitive functions
    modifier onlyMunicipalityManager() {
        // check that the address calling a function is a municipalityManagers otherwise raise an error
        // to do so we can use the has() function defined inside the Roles library
        // that returns true if an address has a specific role and false otherwise
        require(municipalityManagers.has(msg.sender) == true, "Must have the municipalityManagers permission!");
        // if the above requirement is satisfied continue with the function call
        _;
    }
    
    // define a modifier than makes sure that only addresses with the garbageCollectorRole can call some functions
    modifier onlyGarbageCollector() {
        // check that the address calling a function has the garbageCollectorRole otherwise raise an error
        require(garbageCollectorRole.has(msg.sender) == true, "Must have the garbageCollectorRole permission!");
        // if the above requirement is satisfied continue with the function call
        _;
    }
    
    // define a modifier than makes sure that only addresses with the citizenRole can call some functions
    modifier onlyCitizenRole() {
        // check that the address calling a function has the citizenRole otherwise raise an error
        require(citizenRole.has(msg.sender) == true, "Must have the citizenRole permission!");
        // if the above requirement is satisfied continue with the function call
        _;
    }
    
    // create a modifier to check whether a citizen has already paid the deposit 
    // the idea is that only a citizen who already paid the deposit should be able to generate a trash bag
    modifier isDepositPaid() {
        // check whether the citizen has already paid the deposit otherwise raise raise an error
        require(citizens[msg.sender].paidDeposit == true, "You have to pay the deposit before you can continue!");
        _;
    }
    
    // create a modifier to check whether a citizen has already paid the deposit 
    // this time the idea is that only a citizen who has not already paid the deposit should be allowed to pay it  
    // it's basically the opposite of the isDepositPaid() modifier
    modifier canIPayDeposit() {
        // check whether the citizen has not paid the deposit otherwise raise raise an error
        require(citizens[msg.sender].paidDeposit == false, "You have to pay the deposit before you can continue!");
        _;
    }
    
    // create a modifier so that people cannot call the addCitizen() function twice
    modifier isntCitizenYet() {
        // check if the addressExists field of the citizen calling this function is false
        require(citizens[msg.sender].addressExists == false);
        _;
    } 
    
    // declare variables that will be stored in the blockchain
    
    // declare the initial deposit the every citizen will have to pay
    // for now we set it to approximately 1/10 ETH ~ 50 €
    uint constant deposit = 1 * 10 ** 17 wei; 
    // since we defined `deposit` as a unit we cannot subtract it from the amount of taxes due by a citizen when he actually pays the deposit
    // therefore we also decleare the negative of the deposit as a int to be used for that specific computation
    int constant negativeDeposit = - 1 * 10 ** 17 wei;
    
    // declare a mapping that contains many instances of Citizen. As a key we need to use something that is specific 
    // to the singular citizen so we can use either the ethereum address of the citizen or the fiscalCode 
    // for now we decided to use the ethereum address
    // this mapping will be called citizens
    mapping(address => Citizen) citizens;
    
    // create a struct where to store data regarding the individual citizens
    struct Citizen {
        
        // adding the address here is redundant
        // address citizenAddress; // the ethereum address of the citizen, uniquely identifies a citizen
        
        // we don't really need the fiscal code 
        // string fiscalCode; // this variable can also uniquely identify each citizen
                           // maybe its better to use bytes32 data type for this variable. 
            
        bool paidDeposit; // checks whether the citizen paid the deposit or not
                          // we can add a check to make sure the citizen paid the deposit during the current year
        
        int taxesDue; // the amount of taxes the citizen needs to pay to the Municipality
                      // since each citizen pays an initial deposit this number can also be negative 
                      
        uint totalRecyclableWaste; // keep track of the recycable waste produced the particular citizen
        uint totalNonRecyclableWaste; // keep track of the unrecycable waste produced the particular citizen
        
        uint trashBagCount; // how many trash bags the citizen produced so far. This is not used to keep track of how many
                            // trash bags the citizen produced because it will eventually overflow. Instead, it's used 
                            // as a component to compute the unique id of each trash bag
                            
        bool addressExists; // we will use this variable to make sure citizens can call the addCitizen() function only once
                            // if we look up an address in the citizens mapping that was not previusly added this variable 
                            // will be false by default so that 
    }
    
    
    // create a function to instantiate citizens and add them to the citizens mapping
    // it will be external so that it can be called from outside this contract
    // anyone will be able to call this function and will be assigned the citizenRole by default
    // however every citizen should be allowed to call this function only once
    function addCitizen() external isntCitizenYet() {
        // create an instance of Citizen and pass the variables explicitely
        Citizen memory citizen = Citizen({
            // OLD: citizenAddress: msg.sender, // the address calling this function will be saved as the citizenAddress
            // OLD: fiscalCode: _fiscalCode, // set the fiscalCode to the one provided by the citizen
            paidDeposit: false, // initially set the paidDeposit variable to false
            taxesDue: 0, // initially set taxesDue to 0
            totalRecyclableWaste: 0, 
            totalNonRecyclableWaste: 0,
            trashBagCount: 0, // start the trash bag count to zero 
            addressExists: true // set the value to true so that when we look up this address we know it was created
        });
        
        // add the instance of Citizen we just created to the mapping containing all the instances of citizens that is saved on the blockchain.
        // as the key of the mapping we use the ethereum address of the citizen and the value associated with it 
        // is the instance itself of the Citizen struct we just created
        citizens[msg.sender] = citizen;
        // OLD: citizens[citizen.citizenAddress] = citizen;
        
        // give the caller of this function the citizenRole
        _addCitizenRole(msg.sender);
    }
    
    // create a function that can be called by individual citizens in order to pay the initial deposit. 
    // To do so, it will need to be external and payable
    // the amount will be sent to this contract that is owned by the municipality
    // the isDepositPaid() modifier makes sure that a citizen pays the deposit only once
    // {potentially expand it so that one citizen can pay the deposit of another citizen}
    function payDeposit() external payable canIPayDeposit() {
        // make sure that the amount sent using this function is at least equal to the deposit required (1/10 ETH)
        // otherwise revert the transaction
        // the value sent can be accessed using msg.value
        if(msg.value >= deposit){
            // change the paidDeposit variable of the citizen who paid the deposit to true
            citizens[msg.sender].paidDeposit = true;
            // remove the deposit from the taxesDue by this citizen. WARNING: SafaMath only works with uint256 so we cannot use it here
            citizens[msg.sender].taxesDue += negativeDeposit;
        } else {
            // revert the transaction
            revert("The amount you are sending is not enough to cover the deposit");
        }
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // TRASH BAGS MANAGEMENT
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // NEW ADDITIONS
    // create an enum to define the type of waste in a given trash bag
    // initially we will include types such as Nonrecyclable, Paper, Palstic, Organic, Glass but it can be easily expanded
    enum WasteType {Nonrecyclable, Paper, Plastic, Organic, Glass} //lifecycle of the trash bag
    // We cannot trust that citizens will tell the truth about the type of waste their are putting out
    // indeed, they will always have incentives to say that the type is anything other than `Unkown` or `Nonrecyclable`
    
    struct Truck {
        uint totWeight;
        uint depositedStation;
        WasteType wasteType;
    }
    
    mapping(address => Truck) trucks;
    
    function addTruck(address _newTruck, WasteType _wasteType) external onlyMunicipalityManager() {
        Truck memory myTruck = Truck(0, 0, _wasteType);
        trucks[_newTruck] = myTruck;
        _addGarbageCollectorRole(_newTruck);
    }
    
    // Struct to define the gps coordinates of a station. Since latitudes and longitudes are floats (with 13 numbers after the dot),
    // we basically store the information about latitude and longitude by multiplying the respective values by the variable SCALE = 10**13
    uint256 private constant SCALE = 10 ** 13;
    
    struct Station {
        int latitude; 
        int longitude;
        WasteType allowedWasteType;
    }
    
    // Mapping of stations defined by the municipality
    mapping (address => Station) stations;
    
    
    Roles.Role private disposalStationRole;
    
    function _addDisposalStationRole(address _newDisposalStation) private onlyMunicipalityManager() {
        disposalStationRole.add(_newDisposalStation);
    }
    
    function _removeDisposalStationRole(address _oldDisposalStation) private onlyMunicipalityManager() {
        disposalStationRole.remove(_oldDisposalStation);
    }
    
    function addStation(address _newStation, int _latitude, int _longitude, WasteType _wasteType) external onlyMunicipalityManager() {
        Station memory myStation = Station(_latitude, _longitude, _wasteType);
        stations[_newStation] = myStation;
        _addDisposalStationRole(_newStation);
    }

    modifier onlyDisposalStationRole() {
        // check that the address calling a function has the disposalStationRole otherwise raise an error
        require(disposalStationRole.has(msg.sender) == true, "Must have the disposalStationRole permission!");
        // if the above requirement is satisfied continue with the function call
        _;
    }
    

    
    // creates events for each possible state to be communicated outside the chain
    // each event will communicate to the external world the unique id of the trash bag and other relevant information 
    // because of the scalability issues we decided to take an approach based on events. 
    
    // the first event communicates that the trash bag has been collected.  
    // in particular it logs the ethereum address of the citizen who generated the trash bag,
    // the ethereum address of the garbage collector, the time in which the trash bag was picked up, the weight of the trash bag
    // and the type of waste it contains
    event PickedUp(address transporter, WasteType wasteType, bytes32 bagId, address generator, uint wasteWeight, uint pickUpTime);
    
    // the second event communicates that the disposal plant received the trashbag
    event Deposited(address transporter, WasteType wasteType, uint totWeight, address disposalPlant);
    
    event Received(address disposalStation, address transporter);
    
    // create a function to compute the unique id of each bag
    // to get a unique id for a trash bag we can take the hash of the address of the citizen who generated the bag, the time in which
    // it was generated and the number of bags generated by that citizen.
    // Since we will pass the necessary data as parameters it wil be a pure function 
    function _computeUniqueIdTrashBag(address _generator, uint _pickUpTime, uint _trashBagCount) private pure returns(bytes32) {
        // return the hash of the address who generated the trash bag, the time in which the bag was generated 
        // and the number of bash the citizen generated so far
        // in order to pass elements of different tyoe into the keccak256 function we first need to call abi.encodePacked()
        return keccak256(abi.encodePacked(_generator, _pickUpTime, _trashBagCount));
    }
    

    // create a function only addresses having the garbageCollectorRole can call
    // We assume that this function is able to read from a sensor present on the trash bag the ethereum address of the citizen who generated it
    // Moreover, it will get the weight of the trash bag while the garbage collector checks its content (plastic, paper, organic) 
    // Then, it will increase either the totalNonRecyclableWaste or totalRecyclableWaste field of the citizen who generated the trash bag
    // Finally it will emit an event containing all the previous information plus the ethereum address of the garbage collector
    function pickFromBin(address _generator, uint _wasteWeight) external onlyGarbageCollector() {
        // create placeholder for the arguments the function takes as input
        // these variables will be stored in memory and not on the blockchain
        //address generator;
        //uint wasteWeight;
        //WasteType wasteType;
        
        // assign the values to the placeholders created above
        //generator = _generator;
        //wasteWeight = _wasteWeight;
        //wasteType = _wasteType;
        
        // this variable is not stored on the blockchain but will be used when emitting the event
        bytes32 uniqueBagId;
        
        // compute the uniqueBagId using the function defined above
        uniqueBagId = _computeUniqueIdTrashBag(_generator, now, citizens[_generator].trashBagCount);
        
        // Type of waste the truck is carrying
        WasteType _wasteType = trucks[msg.sender].wasteType;
        
        // Increase the total weight that the truck is carrying
        trucks[msg.sender].totWeight = trucks[msg.sender].totWeight.add(_wasteWeight);
        
        // if the WasteType of the trash bag is Nonrecyclable, increment the totalNonRecyclableWaste field of the citizen by the weight of trash bag
        if(_wasteType == WasteType.Nonrecyclable){
            //citizens[_generator].totalNonRecyclableWaste += _wasteWeight;
            // ideally we would use the SafeMath method .add() for this addition
            citizens[_generator].totalNonRecyclableWaste.add(_wasteWeight);
        } else {
            // increment the totalRecyclableWaste field of the citizen by the weight of trash bag 
            //citizens[_generator].totalRecyclableWaste += wasteWeight;
            // ideally we would use the SafeMath method .add() for this addition
            citizens[_generator].totalRecyclableWaste.add(_wasteWeight);
        }
        
        // emit the PickedUp event containing the information regarding the citizen who generated the trash bag, the address of the 
        // garbage collector, the time in which the trash bas was collected, its weight and its type
        emit PickedUp(msg.sender, _wasteType, uniqueBagId, _generator, _wasteWeight, now);
    }
    
    
    function dropAtStation(address _disposalStation, int _latitudeTruck, int _longitudeTruck) external onlyGarbageCollector() {
        //check gps coordinates
        require(stations[_disposalStation].latitude == _latitudeTruck && stations[_disposalStation].longitude == _longitudeTruck, "You are in the worng place!");
        // check WasteType
        require(trucks[msg.sender].wasteType == stations[_disposalStation].allowedWasteType, "You are at the wrong station!");
        
        emit Deposited(msg.sender, trucks[msg.sender].wasteType, trucks[msg.sender].totWeight, _disposalStation);
        
        trucks[msg.sender].depositedStation = trucks[msg.sender].totWeight;
        
        trucks[msg.sender].totWeight = 0;
    }

    
    function receivedWaste(uint _wasteReceived, address _truck) external onlyDisposalStationRole() {
       require(_wasteReceived ==  trucks[_truck].depositedStation, "the truck is fooling you!");
       trucks[_truck].depositedStation = 0;
       emit Received(msg.sender, _truck);
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    // create a function that returns the total amount of money sent to this contract by a citizen
    // since it does not modify the data it will be a view function
    function getTotalTaxesPaid() external view onlyMunicipalityManager() returns(uint) {
       return address(this).balance;
    }
    
    // create a function to check the balance of taxes due by a citizen so far
    // since it does not modify any data it will be a view function
    function getTaxesDue() external view returns(int) {
        // we assume that the address calling this function is the oen of the citizen itself
        return citizens[msg.sender].taxesDue;
    }
    
    // create some functions to access the variables inside the struct of a citizen 
    // create functions to check if you paid the deposit 
    function didIPayDeposit() external view  returns(bool) {
        return citizens[msg.sender].paidDeposit;
    }
    
    // create a function to check the amount of recyclabe waste you produced so far
    function getAmountRecyclableWaste() external view returns (uint) {
        return citizens[msg.sender].totalRecyclableWaste;
    }
    
    // create a function to check the amount of non-recyclabe waste you produced so far
    function getAmountNonRecyclableWaste() external view returns (uint) {
        return citizens[msg.sender].totalNonRecyclableWaste;
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////
    // OLD FUNCTIONS AND IDEAS
    
    // get the fiscal code
    // function getFiscalCode() external view returns(string) {
    //     return citizens[msg.sender].fiscalCode;
    // }
    
    // // create a function that modify the totalRecyclableWaste associate with a citizen
    // // since totalRecyclableWaste directly affect the taxes that a citizen will pay,
    // // only the people managing the municipality should be able to call it
    // // to achieve this we can use the onlyMunicipalityManager modifier we defined above
    // function _addRecyclableWaste () private onlyMunicipalityManager() {
    // }
    
    // create an enum to define the state in which a trashbag can be found
    // enum TrashBagState {ToPickUp, PickedUp, Deposited} //lifecycle of the trash bag
    // create an instance of TrashBagState that in which the state is set to `ToPickUp` 
    // TrashBagState constant defaultTrashBagState = TrashBagState.ToPickUp;
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    // POTENTIAL EXPANSIONS
    
    // create a function that can be executed only by the owner of the contract (the unicipality itself in our case)
    // at the end of the year that sets the paidDeposit field for every citizen to false
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
}
    
    

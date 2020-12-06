pragma solidity >=0.5.0 <0.6.0; 

/* 
- Disposal station? 
- how can information come from the outside world? E.g. when you throw trash bag in a bin, can information about serialNumberBin and 
  weight of the trash bag be collected automatically and then immediately used (there are sensors placed in bins)? -> ask professor
- event PickedUp -> how to deal with the situation when the collection of waste is not door by door and there could be more trash bags in
  the same bin (maybe even produced by different people?). Do we emit an event for each specific bag, or do we just emit a single event 
  like event PickedUp(uint id, uint serialNumberBin, bool isRecyclable, uint totWeight (tot weight of the trash in the bin, Merkle root
  of the addresses of people who have thrown trash bags in the bin)?;
- change or remove addresses from a specific role
- check for overflows
- transfer -> we shouldn't use it. Change this + attention to possible re-entrancy attacks
- transferMoneyCitizens -> make it that it is possible to call this function only at the end of the year
*/

contract TrashChain {
    
    ////////////// MUNICIPALITY ////////////// 
    
    // Declare the owner of this contract
    address owner;
    
    /* Set the owner of this contract == address of municipality (e.g. owner = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4).
    For simplicity (since we don't know the address of the municipality), now we just set the owner = msg.sender and assume that only 
    the municipality can deploy this first part of the contract */
    constructor() public {
        owner = msg.sender;
    }
    
    // Struct to define the gps coordinates of a station
    struct Station {
        uint latitude; 
        uint longitude;
    }
    
    // List of stations defined by the municipality
    Station[] public stations;
    
    // Declare the initial deposit the every citizen will have to pay
    uint constant deposit = 1 * 10 ** 17 wei; 
    
    // Define a struct for each citizen so that the municipality can check their fiscal situations
    struct Citizen {
        uint taxReductions;
        // check whether the citizen has already paid the deposit
        bool paidDeposit;
        // check whether the municipality has already paid the tax reductions or not 
        // (this avoid that the municipality pays some citizens twice by mistake)
        bool paidReductions; 
        // false by default because that's the zero value of a boolean. We add this to check whether a citizen already exists and has
        // already been assigned to an ethereum address
        bool isExist;
    }
    
    // Mapping to link the ethereum address of each citizen to their fiscal situation defined in the struct Citizen
    mapping (address  => Citizen) citizens;
    
    // Mapping to keep track of the role of each ethereum addresses. There are two possible roles: citizen, and truck
    mapping (address => string) roles;
    
    // Mapping to keep track of what kind of waste (i.e. recyclable or not) each bin collects 
    // uint = serial number of the Bin, bool = isRecyclable 
    mapping (uint => bool) bins;
    
    // Function that allows the munucipality to assign the role of citizen. THe mapping citizens is also here updated
    function assignRoleCitizen (address _address) public {
        // Only the municipality has the power to assign roles
        require(msg.sender == owner);
        
        roles[_address] = "citizen";
        
        if (!citizens[_address].isExist) {
            // When the citizen is initially added to the list, set by default paidDeposit=false and taxReduction = 0
            citizens[_address] = Citizen(0, false, false, true);           
        } 
    }
    
    // Function that allows the munucipality to assign the role of truck
    function assignRoleTruck (address _address) public {
        // Only the municipality has the power to assign roles
        require(msg.sender == owner);
        
        roles[_address] = "truck";
    }
    
    // Function that allows the munucipality to assign the gps coordinates of allowed stations
    function assignCoordinatesStation (uint _latitude, uint _longitude) public {
        // Only the municipality has the power to assign roles
        require(msg.sender == owner);
        
        stations.push(Station(_latitude, _longitude));
    }
    
    // Function that allows the municipality to define what kind of trash each bin collects
    function assignTypeTrash (uint _serialNumberBin, bool _isRecyclable) public {
        // Only the municipality has the power todefine what kind of trash each bin collects
        require(msg.sender == owner);
        
        bins[_serialNumberBin] = _isRecyclable;
    }
    
    
    
    ////////////// TRASH CHAIN  ////////////// 
    
    // placeholder for giving an id to the trashbags (?)
    uint idBag;   
    uint idCollection;
    uint idDeposited;
    
    // mapping to keep track of the total amount of recyclable waste produced by each user
    mapping(address => uint) public totalRecyclableWaste; 
    // mapping to keep track of the total amount of non-recyclable waste produced by each user
    mapping(address => uint) public totalNonRecyclableWaste;
    
    // Struct to store information about single trash bag
    struct Bag {
        bool isRecyclable;
        uint weight;
        address generator;
    }

    // mapping to keep track of the information of trash bags in each bin (uint in the mapping = serialNumberBin)
    mapping (uint => Bag[]) private wasteInBin;
    // Mapping to keep track of the information of trash bags in each truck
    mapping (address => Bag[]) private wasteInTruck;

    
    /* What follows is a series of events for the trash bags: 
        - id = unique identifier of trash bag
        - isRecyclable = recyclable/not reciclable indicator
        - weight = weight of the trash bag (comes from the scale located in each bin)
        - serialNumberBin = serial number of each bin
        - generator = ethereum address of the individual/household who has generated the trash bag
        - transporter = ethereum address of the waste truck 
        - Station = gps coordinates of disposal station
    */
    
    // Event that signals that a trash bag has been generated (trash bag is thrown in the bin).
    event ToPickUp(uint id, uint serialNumberBin, bool isRecyclable, uint weight, address generator);
    
    // Event that signals a trash bag in a specific bin has been picked up.
    event PickedUp(uint id, uint serialNumberBin, bool isRecyclable, uint weight, address generator, address transporter);
    
    // Event that signals that a trash bag has been deposited to the station 
    event Deposited(uint id, address transporter, bool isRecyclable, uint weight, address generator, uint station_id);


    /*
    Functions for the lifecycle of the trashbags
    */
    
    // Function to generate trash bags. 
    function generateTbag(uint _weight, uint _serialNumberBin) public {
        // Only citizens can call this function
        require (keccak256(abi.encodePacked(roles[msg.sender])) == keccak256(abi.encodePacked("citizen")));
        
        // Compute the necessary variables and emit the event
        bool isRecyclable = bins[_serialNumberBin];
        emit ToPickUp(idBag, _serialNumberBin, isRecyclable, _weight, msg.sender); 
        
        // Increase either totalRecyclableWaste or totalNonRecyclableWaste of msg.sender on the basis of the type of trash bag
        if (isRecyclable == true) {
            totalRecyclableWaste[msg.sender] = totalRecyclableWaste[msg.sender] + _weight;
        } else {
            totalNonRecyclableWaste[msg.sender] = totalNonRecyclableWaste[msg.sender] + _weight;
        }
        
        // Update the mapping wasteInBin with the information of the bag that has just been thrown
        wasteInBin[_serialNumberBin].push(Bag(isRecyclable, _weight, msg.sender));

        // Increase the count of idBag
        idBag++;
    }


    // Function for the pick up of trash bags.            
    function pickFromBin(uint _serialNumberBin) public { 
        // Only trucks can call this function 
        require (keccak256(abi.encodePacked(roles[msg.sender])) == keccak256(abi.encodePacked("truck")));
        
        // Compute the necessary variables and emit the event
        bool isRecyclable = bins[_serialNumberBin];
        Bag[] storage bags = wasteInBin[_serialNumberBin];
        wasteInTruck[msg.sender] = bags;
        for (uint i=0; i < bags.length; i++) {
            Bag memory myBag = bags[i];
            emit PickedUp(idCollection, _serialNumberBin, isRecyclable, myBag.weight, myBag.generator, msg.sender);
            
        }
        
        // Reset the mapping wasteInBin, since now the bin has been emptied (trash bags have been collected). 
        // The following command clear the array completely (to save space)
        delete wasteInBin[_serialNumberBin];
        
        // Increase the count of idCollection
        idCollection++;
    }

    // Function to check whether the final gps coordinates of the truck == location of an allowed station
    function _checkFinalDestiantion (uint _latitude, uint _longitude) private view returns (bool, uint) {
        bool result = false;
        uint station_id = stations.length + 1;
        for (uint i=0; i < stations.length; i++) {
            Station memory myStation = stations[i];
            if (myStation.latitude == _latitude && myStation.longitude == _longitude) {
                result = true;
                station_id = i;
            }
        }
        return (result, station_id);
    }
        
    // Function for the dumping of trash bags in the disposal station
    function dropAtPlant(uint _latitude, uint _longitude) public { 
        // Only trucks can call this function 
        require (keccak256(abi.encodePacked(roles[msg.sender])) == keccak256(abi.encodePacked("truck")));
        // Waste can be dumped only at allowed disposal stations
        (bool result, uint station_id) = _checkFinalDestiantion(_latitude, _longitude);
        require(result == true);
        
        // Compute the necessary variables and emit the event
        Bag[] storage bags = wasteInTruck[msg.sender];
        for (uint i=0; i < bags.length; i++) {
            Bag memory myBag = bags[i];
            emit Deposited(idDeposited, msg.sender, myBag.isRecyclable, myBag.weight, myBag.generator, station_id);
        }
        
        // Reset the mapping wasteInTruck
        delete wasteInTruck[msg.sender];
    }
    
    
    //////////////////// TAXES /////////////////////
    
    // Define a function to pay the deposit 
    function payDeposit() external payable {
        require(citizens[msg.sender].isExist == true);
        
        if(msg.value >= deposit){
            // change the paidDeposit variable of the citizen who paid the deposit to true
            citizens[msg.sender].paidDeposit = true;
        } else {
            // revert the transaction
            revert("The amount you are sending is not enough to cover the deposit");
        }
    }
    
    // Function to check the balance of the contract
    function checkContractBalance() public view returns(uint) {
        return address(this).balance;
    }
    
    // Function to allow the municipality to withdraw the deposits
    function withdrawAll() public {
        // only the municipality can withdraw funds
        require (msg.sender == owner);
        
        address payable to = msg.sender;
        to.transfer(this.checkContractBalance());
    }
    
    /* Function to determine the amount of tax reductions awarded by each citizen
        - if the citizen recycles less of 40% of tot waste, no tax reduction
        - if the citizen recycles between 40% and 50% of tot waste, then 5% tax reduction
        - if the citizen recycles between 50% and 70% of tot waste, then 10% tax reduction
        - if the citizen recycles between 70% and 90% of tot waste, then 20% tax reduction
        - if the citizen recycles more than 90% of tot waste, then 30% tax reduction
    NB: percentages of tax reduction to be computed on the deposit, which in this case = 50 euros
    */
    function _determineTaxReductions (address _address) private returns (uint) {
        // Define the amount of tax reduction awarded
        uint taxReduction;
        
        // Rename relevant variables for simplicity
        uint sum = totalRecyclableWaste[_address] + totalNonRecyclableWaste[_address];
        // Since solidity does not support floats, we multiply by 100
        uint amountRecycled = totalRecyclableWaste[_address]/sum * 100;
        
        // Different cases that determine the amount of tax reduction that the citizen in question has awarded
        if (amountRecycled < 40) {
            taxReduction = 0;
        }
        
        if (amountRecycled >= 40 && amountRecycled < 50) {
            taxReduction = 5 * 10 ** 15 wei; // 5% of the deposit
        }
        
        if (amountRecycled >= 50 && amountRecycled < 70) {
            taxReduction = 1 * 10 ** 16 wei; // 10% of the deposit
        }
        
        if (amountRecycled >= 70 && amountRecycled < 90) {
            taxReduction = 2 * 10 ** 16 wei; // 20% of the deposit
        }
        
        if (amountRecycled >= 90) {
            taxReduction = 3 * 10 ** 16 wei; // 30% of the deposit
        }
        
        // Update the variable taxReduction for the citizen in question
        citizens[_address].taxReductions = taxReduction;
        
        return taxReduction;
    }
    
    // Function to transfer the money to citizens on the basis of the amount of taxes they have awarded 
    function transferMoneyCitizens (address payable _address) public {
        // Only the municipality has the power to trasnfer money to citizens
        require (msg.sender == owner);
        // Check whether the address is the existing address of a citizen
        require (citizens[_address].isExist == true);
        // Check that the municipality has not paid the citizen in question yet
        require (!citizens[_address].paidReductions);
        
        // Define the amount that the municipality has to pay to the citizen
        uint taxReduction = _determineTaxReductions(_address);
        
        // Set the variable paidReductions for the citizen = true
        citizens[_address].paidReductions = true;
        
        // Transfer the money
        _address.transfer(taxReduction);
        
    }
    
    
}

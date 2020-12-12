pragma solidity ^0.6.0; 

// Import Agents contract, used by the Municipality to create structs of citizens, trucks and disposal stations
import "agents.sol";

contract TrashLife is Agents {
    
    // Define a modifier so that certain functions can only be called by Ethereum addresses associated with existing citizens
    modifier onlyCitizen() {
        require(citizens[msg.sender].active == true, "Must have the citizen permission!");
        _;
    }
    
    // Define a modifier so that certain functions can only be called by Ethereum addresses associated with existing stations
    modifier onlyStation() {
        require(stations[msg.sender].active == true, "Must have the station permission!");
        _;
    }
    
    // Define a modifier so that certain functions can only be called by Ethereum addresses associated with existing trucks
    modifier onlyTruck() {
        require(trucks[msg.sender].active == true, "Must have the truck permission!");
        _;
    }
    
    // The Municipality can withdraw ETH from the balance of this contract only once per year. To avoid double withdraws, the 
    // following variable is set to false until the withdraw takes place. 
    bool _withdraw = false;
    
    
    
    /////////////////////////  TARI PAYMENT  /////////////////////////
    
    // Define an event to signal that a citizen has paid the TARI and when this happened
    event PayedTari(address _citizen, uint _time);
    
    /* Define fixed fees to compute the TARI amount each citizen must pay; the TARI amount is defined as the sum of two parts:
        1. Square meters of the house times a fee depending on the number of household members: If there are 4 or less people in the household, 
        the deposit_mq_less4 fee applies, it corresponds to about 1 €/mq. If there are more than 4 people, deposit_mq_more4 applies, that is about 2€/mq.
        2. Total waste produced by the household the previous year times a constant fee: Waste is measured in kg. The fee, deposit_trash, doesn't depend on 
        anything and it's about 5 cents/kg. */
    uint constant deposit_mq_less4 = 2 * 10 **15; 
    uint constant deposit_mq_more4 = 4 * 10 **15;
    uint constant deposit_trash = 1 * 10 **14;
    
    // Define a function, only for the Municipaliy, to check the balance of the contract at a given point in time
    function MunicipalityBalance() public view onlyOwner returns(uint) {return address(this).balance;}
    
    // Define a function to compute how much TARI a given citizen has to pay. It is invoked at the beginning of the year by the Municipality, 
    // that is in charge of informing each citizen 
    function TariAmount(address _address) public onlyOwner {
        // Verify _address is associted with an existing citizen 
        require(citizens[_address].active == true, "Address is not a citizen!");
        // Verify the citizen has not paid the TARI yet. This is to avoid that the citizen pays twice in a year
        require(citizens[_address].payTARI == false, "You have alredy paid the TARI!");
        
        uint TARI = 0; 
        if(citizens[_address].family <= 4) {
            TARI = deposit_mq_less4 * citizens[_address].house + deposit_trash * citizens[_address].weight;
        } else {
            TARI = deposit_mq_more4 * citizens[_address].house + deposit_trash * citizens[_address].weight;
        }
        // Update the TARI variable in the struct of each citizen
        citizens[_address].TARI = TARI;
    }
    
    // Define a function, only for citizens, to pay the exact amount of TARI. Amounts are expressend in wei and stored in this contract. 
    function payTari() external payable onlyCitizen {
        // Verify the citizen has not paid the TARI yet. This is to avoid that the citizen pays twice in a year 
        require(citizens[msg.sender].payTARI == false, "You have alredy paied the TARI!");

        // Verify the citizen is paying the correct amount of money
        if(msg.value == citizens[msg.sender].TARI) {
            citizens[msg.sender].payTARI = true;
            citizens[msg.sender].weight = 0; 
            emit PayedTari(msg.sender, now);
        } else {
                // If the citizen pays a different wei amount, the payment is reverted
                revert("The amount you are sending doesn't correspond to the TARI you have to pay!");
            }
    }
    
    
    
    /////////////////////////  TRASH CYCLE /////////////////////////

    // Define the events that are going to keep track of the life cycle of each trash bag
    event PickedUp(address transporter, bool wasteType, bytes32 bagId, address generator, uint wasteWeight, uint pickUpTime);
    event Deposited(address transporter, bool wasteType, uint totWeight, address disposalPlant);
    event Received(address disposalStation, address transporter);
    
    // Define a function to uniquely identify a trash bag
    function _computeIdBag(address _citizen, uint _pickUpTime, uint _random) private pure returns(bytes32) {
        return keccak256(abi.encodePacked(_citizen, _pickUpTime, _random));
    }
    
    /* Define a function to regsiter the pick up of trash bags. Only truck drivers can call this function, specifying:
        - the address of the citizen the bag belongs to: printed on the bag and scanned by the truck driver;
        - the weight of the bag: provided by a scale included in the truck;
        - a random integer to ensure the hash-ID of the bag is really unique.*/
    function pick(address _citizen, uint _wasteWeight, uint _random) external onlyTruck() {
        bytes32 uniqueBagId = _computeIdBag(_citizen, now, _random);
        // Increase the weight attribute of the truck by the weight of each bag it picks up
        trucks[msg.sender].weight = trucks[msg.sender].weight.add(_wasteWeight);
        
        if(trucks[msg.sender].waste == false){
            citizens[_citizen].totalNonRecyclableWaste = citizens[_citizen].totalNonRecyclableWaste.add(_wasteWeight);
            // Increase the weight of NON-recyclable waste the citizen has produced in this year 
        } else {citizens[_citizen].totalRecyclableWaste = citizens[_citizen].totalRecyclableWaste.add(_wasteWeight);}
            // Increase the weight of recyclable waste the citizen has produced in this year 
     
        emit PickedUp(msg.sender, trucks[msg.sender].waste, uniqueBagId, _citizen, _wasteWeight, now);
    }
    
    /* Define a function to register the dumping of trash bags at the appropriate disposal station. Only truck drivers can call this function, specifying:
        - the address of the station they are at;
        - the longitude and latitude of their position: provided directly by their GPS coordinates. */
    function drop(address _disposalStation, int _latitudeTruck, int _longitudeTruck) external onlyTruck() {
        // Verify the GPS coordinates of the truck correspond to the location of an approved disposal station
        require(stations[_disposalStation].latitude == _latitudeTruck && stations[_disposalStation].longitude == _longitudeTruck, 
            "You are at the wrong station!");
        // Verify the truck is at the right station on the basis of the type of waste it is carrying (recyclable or non-recyclable)
        require(trucks[msg.sender].waste == stations[_disposalStation].waste, "You are at the wrong station!");
        
        emit Deposited(msg.sender, trucks[msg.sender].waste, trucks[msg.sender].weight, _disposalStation);
        // Increase the weight attribute of the station by the total weight of waste dropped by the truck
        stations[_disposalStation].weight = stations[_disposalStation].weight.add(trucks[msg.sender].weight);
        // Reset the weight attribute of the truck since it's now empty 
        trucks[msg.sender].weight = 0;

    }
    
    /* Define a function to verify whether there is cohorence between the total amount of trash that a station declares to have received
    up to now, and the amount of trash that has been actually dumped to the station by trucks over time. This function can only be 
    called by a station whenever a truck arrives and dumps its content. In particular, when calling this function, the station has to 
    specify the address of the truck in question, the type of waste that the station disposes and the total weight of trash that has been
    dumped to the station so far.*/
    function received(bool _waste, address _truck, uint _weight) external onlyStation() {
        // Verify the coherence between the waste type (recyclable or not) of the truck and the station
        // Verify the total amount of waste at the station (previous amount + weight of trash dumped by the 
        // truck in question) is equal to the amount of waste that the station declares to have received up to now (i.e. _weight).
        require(trucks[_truck].waste == _waste && stations[msg.sender].weight == _weight);
        emit Received(msg.sender, _truck);
    }
    
    
    
    /////////////////////////  PAYOUTS  /////////////////////////
    
    // Define an event to signal that the municipality has paid the respective payout to a citizen, including payment amount and time
    event PayedPayout (address _address, uint _value, uint _time);
    
    // Define a function to compute, at the end of the year, the payout a citizen is entitled to
    function _computePayout(address payable _citizen) private view returns(uint) {
        // Get the total amount of waste a citizen has generated during the current year
        uint totalW = citizens[_citizen].totalRecyclableWaste.add(citizens[_citizen].totalNonRecyclableWaste);
        // Compute the percentage of recyclable waste
        uint percentageRecycle = citizens[_citizen].totalRecyclableWaste.mul(100).div(totalW);
        
        // If this percentage is below 25% the citizen is not eligible for a reimburse 
        if (percentageRecycle <= 25) {
            return 0; 
        } 
        // If this percentage is between 25% and 50% the citizen receives back 2% of the TARI paid at the beginning of the year
        if (percentageRecycle <= 50 && percentageRecycle > 25) {
            return citizens[_citizen].TARI.mul(2).div(100);
        }
        // If this percentage is between 50% and 75% the citizen receives back 5% of the TARI paid at the beginning of the year
        if (percentageRecycle > 50 && percentageRecycle <= 75) {
            return citizens[_citizen].TARI.mul(5).div(100);
        }
        // If this percentage is above 75% the citizen receives back 10% of the TARI paid at the beginning of the year
        if (percentageRecycle > 75) {
            return citizens[_citizen].TARI.mul(10).div(100);
        }
        
    }
    
    // Define a function that allows the Municipality to withdraw some funds from the contract before the end of the year
    function withdraw() public onlyOwner returns(uint){
        // For simplicity the municipality can call this function only once every year
        require (_withdraw == false);
        _withdraw = true;
        // The municipality can withdraw 88% of the funds stored in this contract, since they won't be necessary for any payout
        uint balance = (address(this).balance).mul(88).div(100);
        address payable to = msg.sender; 
        (bool success, ) = to.call{value:balance}("");
        require(success, "External transfer failed!");
        return balance;
    }

    // Define whether it is the appropriate time to call "givePayout", since payouts must be payed at the end of the year 
    function _isAppropriateTime() private view onlyOwner returns(bool) {
        uint date1 = start + 353 days; // From 20th December 
        uint date2 = start + 361 days; // To 28th December
        bool appropriate;
        if (now >= date1 && now <= date2) {
            appropriate = true;
        }
        return appropriate; 
    }
    
    // Define a function to allow the Municipality paying the payouts 
    function givePayout(address payable _citizen) external payable onlyOwner {
        // Check that the address _citizen is associted with an existing citizen, and that the citizen in question has already paid the TARI
        require(citizens[_citizen].active == true && citizens[_citizen].payTARI == true);
        // Check whether it is the appropriate time for the municipality to call this function. This line of code is commented for the 
        // purposes of the Python simulation. 
        //require (_isAppropriateTime() == true);
        
        // Compute the payout earned by the citizen, and check whether the contract has enough funds to pay the due amount
        uint payout = _computePayout(_citizen);
        require(address(this).balance > payout, "Municipality has not enough funds!");
        // Set the "payTARI" attribute of the citizen equal to false to avoid reetrancy attacks 
        citizens[_citizen].payTARI = false;
        
        (bool success, ) = _citizen.call{value:payout}("");
        require(success, "External transfer failed!");
        emit PayedPayout (_citizen, payout, now);
    }
    
    /* Define a function to ensure that the "destroyContract" function can only be called by the municipality after 29th December, i.e. 
    when the "givePayout" function is not callable anymore. The municipality is therefore not allowed to call the "destroyContract" 
    function whenever they want (for example in June), because they would otherwise be able get all the money stored in the contract  
    and avoid reimbursing the citizens at the end of the year on the basis of their recycling behaviors. */
    function _timeToDestroyContract() private view onlyOwner returns(bool) {
        uint date = start + 362 days;
        bool appropriate;
        if (now >= date) {
            appropriate = true;
        }
        return appropriate;
    }

    /* Define a function to destroy the contract at the end of each year. Only the Municipality can call it
    function destroyContract() public onlyOwner {
        // Check whether it is the appropriate time for the municipality to call this function. 
        //require(_timeToDestroyContract() == true); // commented for the purpose of Python test
        selfdestruct(msg.sender);
        // The contract balance is automatically transferred to msg.sender, that is the Municipality
    }
    
}

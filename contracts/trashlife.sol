pragma solidity ^0.6.0; 

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
    
    
    // Set the varible _withdraw equal to false to ensure that the municipality can call the "withdraw" function only once during the year
    bool _withdraw = false;
    
    
    // Define an event to signal that a citizen has paid the TARI
    event PayedTari(address _citizen, uint _time);
    
    /* Assign some constant values to the variables deposit_mq_less4, deposit_mq_more4 and deposit_trash, that are going to be needed for 
    the computation of the TARI. In particular, the TARI is here given by the sum of two parts:
        - the first part is given by the product of the square meters of the house and a fixed fee which depends on the number of people in 
          the  household. If there are less than four people in the household, the fee deposit_mq_less4 applies, whereas if the household
          has more than four members, the fee deposit_mq_more4 applies.
        - the second part is variable and depends on the total amount of waste produced by the household the year before. To be more 
          specific, the total weight of waste produced by the household the year before is multiplied by a constant amount of money, i.e.
          deposit_trash.
    */
    uint constant deposit_mq_less4 = 2 * 10 **15; //2.mul(10**15); // 1 euro
    uint constant deposit_mq_more4 = 4 * 10 **15; //4.mul(10**15); // 2 euro
    uint constant deposit_trash = 1 * 10 **14; // 5 cents
    


    /////////////////////////  TARI  /////////////////////////
    
    // Define a function to check the balance of the contract at a given point in time
    function MunicipalityBalance() external view onlyOwner returns(uint) {return address(this).balance;}
    
    /* Define a function to compute how much TARI a given citizen has to pay. This function is called by the municipality, and the citizen 
    is notified about the amount of TARI he/she has to pay through a text message or an app notification. In this way, citizens do not have 
    to bear the burden of calling this function, and their privacy is also protected. Indeed, other citizens cannot access the specific 
    information about the amount of TARI that they have to pay.*/
    function TariAmount(address _address) public onlyOwner {
        // Check that _address is associted with an existing citizen 
        require(citizens[_address].active == true, "Address is not a citizen!");
        // Verify that the citizen has not paid the TARI yet. This is to avoid that the citizen pays the TARI twice in an year
        require(citizens[_address].payTARI == false, "You have alredy paied the TARI!");
        
        uint TARI = 0; 
        if(citizens[_address].family <= 4) {
            TARI = deposit_mq_less4 * citizens[_address].house + deposit_trash * citizens[_address].weight;
        } else {
            TARI = deposit_mq_more4 * citizens[_address].house + deposit_trash * citizens[_address].weight;
        }
        citizens[_address].TARI = TARI;
    }
    
    /* Define a function that can only be called by a citizen and allows him/her to pay the TARI to the municipality. To be more specific, 
    the citizen sends the money to this contract, which is owned by the municipality */
    function payTari() external payable onlyCitizen {
        // Verify that the citizen has not paid the TARI yet. This is to avoid that the citizen pays the TARI twice in an year 
        require(citizens[msg.sender].payTARI == false, "You have alredy paied the TARI!");

        // This is to check whether the citizen is paying to the municipality the correct amount of money. If the amount that the citizen
        // is sending does not correspond to the TARI he/she has to pay, the payment is reverted
        if(msg.value == citizens[msg.sender].TARI) {
            citizens[msg.sender].payTARI = true;
            citizens[msg.sender].weight = 0; 
            emit PayedTari(msg.sender, now);
        } else {
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
    
    /* Define a function for the pick up of trash bags. Only trucks can call this function. 
    As regards the arguments of the function, the address _citizen comes directly from some sensors placed in each truck, which scan and
    store the information printed on each trash bag. Each truck is also equipped with a scale, so the uint _wasteWeight also comes 
    directly from the external world. The uint random is simply a random number which is needed for computing the unique id of each 
    trash bag.
    */
    function pick(address _citizen, uint _wasteWeight, uint _random) external onlyTruck() {
        bytes32 uniqueBagId = _computeIdBag(_citizen, now, _random);
        trucks[msg.sender].weight = trucks[msg.sender].weight.add(_wasteWeight);
        
        if(trucks[msg.sender].waste == false){
            citizens[_citizen].totalNonRecyclableWaste = citizens[_citizen].totalNonRecyclableWaste.add(_wasteWeight);
        } else {citizens[_citizen].totalRecyclableWaste = citizens[_citizen].totalRecyclableWaste.add(_wasteWeight);}
     
        emit PickedUp(msg.sender, trucks[msg.sender].waste, uniqueBagId, _citizen, _wasteWeight, now);
    }
    
    /* Define a function for the dumping of trash bags at the appropriate disposal station. The function can only be called by trucks, who
    have to specify the address of the station as the input of the function. The two integers _latitudeTruck and _longitudeTruck represent
    instead the GPS coordinates of the trucks, and come directly from the external world. */
    function drop(address _disposalStation, int _latitudeTruck, int _longitudeTruck) external onlyTruck() {
        // Check whether the GPS coordinates of the truck correspond to the location of a disposal station which the municipality
        // has previously approved and included in the mapping stations
        require(stations[_disposalStation].latitude == _latitudeTruck && stations[_disposalStation].longitude == _longitudeTruck, 
            "You are at the wrong station!");
        // Check whether the truck is at the right station on the basis of the type of waste it is carrying (recyclable or non-recyclable)
        require(trucks[msg.sender].waste == stations[_disposalStation].waste, "You are at the wrong station!");
        
        emit Deposited(msg.sender, trucks[msg.sender].waste, trucks[msg.sender].weight, _disposalStation);
        stations[_disposalStation].weight = stations[_disposalStation].weight.add(trucks[msg.sender].weight);
        trucks[msg.sender].weight = 0;
    }
    
    /* Define a function to verify whether there is cohorence between the total amount of trash that a station declares to have received
    up to now, and the amount of trash that has been actually dumped to the station by trucks over time. This function can only be 
    called by a station whenever a truck arrives and dumps its content. In particular, when calling this function, the station has to 
    specify the address of the truck in question, the type of waste that the station disposes and the total weight of trash that has been
    dumped to the station so far.*/
    function received(bool _waste, address _truck, uint _weight) external onlyStation() {
        // Check whether the type of waste that the truck is carrying (recyclable or not) is coherent with the type of waste that the 
        // station disposes, and whether the total amount of waste at the station (previous amount + weight of trash dumped by the 
        // truck in question) is equal to the amount of waste that the station declares to have received up to now (i.e. _weight).
        require(trucks[_truck].waste == _waste && stations[msg.sender].weight == _weight);
        emit Received(msg.sender, _truck);
    }
    
    
    
    /////////////////////////  PAYOUTS  /////////////////////////
    
    // Define an event to signal that the municipality has paid the respective payout to a citizen 
    event PayedPayout (address _address, uint _value, uint _time);
    
    /* Define a function to compute the payout that a citizen has earned during the year. In particular, the payout depends on the
    fraction of recyclable waste produced by the citizen during the year, and is computed as a percentage of the TARI paid
    by the citizen at the beginning of the year */
    function _computePayout(address payable _citizen) private view returns(uint) {
        uint totalW = citizens[_citizen].totalRecyclableWaste.add(citizens[_citizen].totalNonRecyclableWaste);
        uint percentageRecycle = citizens[_citizen].totalRecyclableWaste.mul(100).div(totalW);
        
        if (percentageRecycle <= 25) {
            return 0; 
        } 
        if (percentageRecycle <= 50 && percentageRecycle > 25) {
            return citizens[_citizen].TARI.mul(2).div(100);
        }
        if (percentageRecycle > 50 && percentageRecycle <= 75) {
            return citizens[_citizen].TARI.mul(5).div(100);
        }
        if (percentageRecycle > 75) {
            return citizens[_citizen].TARI.mul(10).div(100);
        }
        
    }
    
    /* Define a function that allows the municipality to withdraw some funds from the contract before the end of the year. In particular, 
    if we supposed that all citizens recycled more than 75% of their waste, the maximum amount that the municipality would have to pay is 
    10% of the total TARI paid by all citizens (i.e. 10% of the money stored in this contract). Therefore, the municipality can safely
    withdraw 88% of the funds stored in this contract and thus enjoy immediate liquidity, without compromising the ability of reimbursing 
    all the citizens at the end of the year. An additional 2% of the funds is kept in the contract to also take into account eventual 
    transaction costs (this is why the municipality can only withdraw 88% of the money stored in the contract and not 90%).*/
    function withdraw() public onlyOwner returns(uint){
        // For simplicity, we assume that the municipality can call this function only once every year
        require (_withdraw == false);
        // The variable _withdraw is set equal to true to avoid potential re-entrancy attacks
        _withdraw = true;
        uint balance = (address(this).balance).mul(88).div(100);
        address payable to = msg.sender; 
        (bool success, ) = to.call{value:balance}("");
        require(success, "External transfer failed!");
        return balance;
    }

    /*Function to define whether it is the appropriate time to call the function "givePayout". The municipality can indeed
    call the "givePayout" function only at the end of each year. In particular, the municipality is allowed to call this function only
    between 20th and 28th of december. This time range was chosen in order to to avoid the potential complications that could arise if, 
    for some reasons, the municipality did not call the "setBeginningYear" function exactly on 1st January, or if the miners took days to 
    mine the block with the "setBeginningYear" function. */
    function _isAppropriateTime() private view onlyOwner returns(bool) {
        uint date1 = start + 353 days;
        uint date2 = start + 361 days;
        bool appropriate;
        if (now >= date1 && now <= date2) {
            appropriate = true;
        }
        return appropriate; 
    }
    
    // Define a function so that the municipality can pay the payouts earned by the citizens 
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

    /* Define a function that allows the municipality to destroy the contract at the end of each year. The money that are still
    stored in the contract when this function is called are sent to the Ethereum address of the municipality. */
    function destroyContract() public onlyOwner {
        // Check whether it is the appropriate time for the municipality to call this function. This line of code is commented for the 
        // purposes of the Python simulation. 
        //require(_timeToDestroyContract() == true);
        selfdestruct(msg.sender);
    }
    
}

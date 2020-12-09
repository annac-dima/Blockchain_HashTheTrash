pragma solidity ^0.6.0; 

import "agents.sol";

contract TrashLife is Agents {
    
    modifier onlyCitizen() {
        require(citizens[msg.sender].active == true, "Must have the citizen permission!");
        _;
    }
    
    modifier onlyStation() {
        require(stations[msg.sender].active == true, "Must have the station permission!");
        _;
    }
    
    modifier onlyTruck() {
        require(trucks[msg.sender].active == true, "Must have the truck permission!");
        _;
    }
    
    event PayedTari(address _citizen, uint _time);
    
    uint constant deposit_mq_less4 = 2 * 10 **15; //2.mul(10**15); // 1 euro
    uint constant deposit_mq_more4 = 4 * 10 **15; //4.mul(10**15); // 2 euro
    uint constant deposit_trash = 1 * 10 **14; // 5 cents
    
    // -- TARI
    function MunicipalityBalance() external view onlyOwner returns(uint) {return address(this).balance;}
    
    function TariAmount(address _address) public onlyOwner {
        require(citizens[_address].active == true, "Address is not a citizen!");
        require(citizens[_address].payTARI == false, "You have alredy paied the TARI!");
        
        uint TARI = 0; 
        if(citizens[_address].family <= 4) {
            TARI = deposit_mq_less4 * citizens[_address].house + deposit_trash * citizens[_address].weight;
        } else {
            TARI = deposit_mq_more4 * citizens[_address].house + deposit_trash * citizens[_address].weight;
        }
        citizens[_address].TARI = TARI;
    }
    
    function payTari() external payable onlyCitizen {
        require(citizens[msg.sender].payTARI == false, "You have alredy paied the TARI!");

        if(msg.value == citizens[msg.sender].TARI) {
            citizens[msg.sender].payTARI = true;
            emit PayedTari(msg.sender, now);
        } else {
                revert("The amount you are sending doesn't correspond to the TARI you have to pay!");
            }
    }
    

    // -- TRASH
    //PLUS: enum WasteType {Nonrecyclable, Paper, Plastic, Organic, Glass}
    //PLUS: reduce uint 
    event PickedUp(address transporter, bool wasteType, bytes32 bagId, address generator, uint wasteWeight, uint pickUpTime);
    event Deposited(address transporter, bool wasteType, uint totWeight, address disposalPlant);
    event Received(address disposalStation, address transporter);
    
    function _computeIdBag(address _citizen, uint _pickUpTime, uint _random) private pure returns(bytes32) {
        return keccak256(abi.encodePacked(_citizen, _pickUpTime, _random));
    }
    
    function pick(address _citizen, uint _wasteWeight, uint _random) external onlyTruck() {
        bytes32 uniqueBagId = _computeIdBag(_citizen, now, _random);
        trucks[msg.sender].weight = trucks[msg.sender].weight.add(_wasteWeight);
        
        if(trucks[msg.sender].waste == false){
            citizens[_citizen].totalNonRecyclableWaste.add(_wasteWeight);
        } else {citizens[_citizen].totalRecyclableWaste.add(_wasteWeight);}
        
        emit PickedUp(msg.sender, trucks[msg.sender].waste, uniqueBagId, _citizen, _wasteWeight, now);
    }
    
    function drop(address _disposalStation, int _latitudeTruck, int _longitudeTruck) external onlyTruck() {
        require(stations[_disposalStation].latitude == _latitudeTruck && stations[_disposalStation].longitude == _longitudeTruck, "You are in the worng place!");
        require(trucks[msg.sender].waste == stations[_disposalStation].waste, "You are at the wrong station!");
        
        emit Deposited(msg.sender, trucks[msg.sender].waste, trucks[msg.sender].weight, _disposalStation);
        stations[_disposalStation].weight = stations[_disposalStation].weight.add(trucks[msg.sender].weight);
        trucks[msg.sender].weight = 0;
    }
    
    function received(bool _waste, address _truck, uint _weight) external onlyStation() {
       require(trucks[_truck].waste == _waste && stations[msg.sender].weight == _weight);
       emit Received(msg.sender, _truck);
    }
    
    // -- PAYOUT
    event PayedPayout (address _address, uint _value, uint _time);
    
    function computePayout(address payable _citizen) private view returns(uint) {
        uint totalW = citizens[_citizen].totalRecyclableWaste.add(citizens[_citizen].totalNonRecyclableWaste);
        uint percentageRecycle = citizens[_citizen].totalRecyclableWaste.div(totalW)*100;
        
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
    
    // CHECK 
    function withdraw() external onlyOwner {
        uint balance = address(this).balance;
        address payable to = msg.sender; 
        (bool success, ) = to.call.value(balance)("");
        require(success, "External transfer failed!");
    }
    
    // CHECK
    function givePayout(address payable _citizen) external payable onlyOwner {
        require(citizens[_citizen].active == true && citizens[_citizen].payTARI == true);
        
        // problema dei rientrance attacks 
        citizens[_citizen].payTARI == false;
        uint payout = computePayout(_citizen);
        require(msg.sender.balance > payout, "Municipality has not enough funds!");
        
        (bool success, ) = _citizen.call.value(payout)("");
        require(success, "External transfer failed!");
        emit PayedPayout (_citizen, payout, now);
    }
 
}

pragma solidity ^0.6.0; 

import "citizen.sol";

contract TrashLife is Agents {
    
    modifier onlyMunicipality() {
        require(municipalities[msg.sender].active == true, "Must have the municipality permission!");
        _;
    }
    
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
    
    modifier payTARI() {
        require(citizens[msg.sender].payTARI == true, "You have to pay the deposit before you can continue!");
        _;
    }
    
    
    uint constant deposit_mq_less4 = 2 * 10 **15; //2.mul(10**15);
    uint constant deposit_mq_more4 = 4 * 10 **15; //4.mul(10**15);
    uint constant deposit_trash = 1 * 10 **14; // 5 cents
    
    // TARI
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
        // Serve il revert se il require da errore?
       
        if(msg.value == citizens[msg.sender].TARI) {
            citizens[msg.sender].payTARI = true;} else {
                revert("The amount you are sending doesn't correspond to the TARI you have to pay!");
            }
    }
    

    // TRASH
    //enum WasteType {Nonrecyclable, Paper, Plastic, Organic, Glass}
    event PickedUp(address transporter, bool wasteType, bytes32 bagId, address generator, uint wasteWeight, uint pickUpTime);
    event Deposited(address transporter, bool wasteType, uint totWeight, address disposalPlant);
    event Received(address disposalStation, address transporter);
    
    function _computeIdBag(address _citizen, uint _pickUpTime, uint _random) private pure returns(bytes32) {
        return keccak256(abi.encodePacked(_citizen, _pickUpTime, _random));
    }
    
    function pick(address _citizen, uint _wasteWeight, uint _random) external onlyTruck() {
        bytes32 uniqueBagId;
        uniqueBagId = _computeIdBag(_citizen, now, _random);
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
    
}
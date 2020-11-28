pragma solidity >=0.6.0 <0.7.0;

// import ownable
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract garbageTaxes is Ownable {
    
    // set up variables
    string name;
    string fiscalCode;
    string homeAddress;
    bool paidDeposit;
    uint taxesDue;
    uint deposit;
    // here maybe we can ass a specific amount for every type of garbage (paper, plastic, glass)
    uint totalRecyclableWaste; 
    uint totalNonRecyclableWaste;
    
    constructor (string memory _name, string memory _fiscalCode, string memory _homeAddress ) public {
        name = _name;
        fiscalCode = _fiscalCode;
        homeAddress = _homeAddress;
        // by default set paidDeposit to false
        paidDeposit = false;
        // also set taxesDue to zero
        taxesDue = 0;
        // set the amount due by every citizen to 1 ETH for now
        deposit = 1;
        totalNonRecyclableWaste = 0;
        totalRecyclableWaste = 0;
    }
      
    // create the event paid deposit
    event sentDeposit(address from, address to, uint amount);
      
    // create function to pay the initial deposit   
    function payDeposit(address payable _municipality) public payable {
        _municipality.transfer(deposit);
        
        // change the paidDeposit variabel to true
        paidDeposit = true;
        
        // emit the sentDeposit event
        emit sentDeposit(msg.sender, _municipality, deposit);
    } 
      
    // create a function that computes how much taxes you have to pay
    // depending on how much waste you produced
    function computeTaxes() public view returns (uint) {
        // since we want to incentivize recycling, it makes sense to make people pay less taxes
        // the more they recycled
        uint taxes = totalNonRecyclableWaste/10 + totalRecyclableWaste/100;
        return taxes;
    }
      
    // create a function to check the balance of taxes due so far
    function getAmountTaxesDue() public view returns (uint) {
        return taxesDue;
    }
    
    // create a function to check the amount of recyclabe waste produces so far
    function getAmountRecyclableWaste() public view returns (uint) {
        return totalRecyclableWaste;
    }
    
    // create a function to check the amount of recyclabe waste produces so far
    function getAmountNonRecyclableWaste() public view returns (uint) {
        return totalNonRecyclableWaste;
    }
    
    // create a function to see if you paid the deposit
    function didIPayTheDeposit() public view returns (bool) {
        return paidDeposit;
    }
}
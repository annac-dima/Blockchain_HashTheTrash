pragma solidity ^0.6.0;
// import ownable
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
// import safemath
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract MunicipalityWasteTaxes is Ownable {
    
    // use safemath for uints and integers 
    using SafeMath for uint;
    using SafeMath for int;
    
    // declare variables that will be stored in the blockchain
    
    // declare the initial deposit the every citizen will have to payable
    // for now we set it to approximately to 1/10 ETH ~ 50 €
    uint deposit = 1 * 10 ** 17 wei; 
    
    // keep track of the total amount of taxes paid by all citizens
    // this is not necessary, this information can be accessed using this.balance
    // uint totalTaxesPaidByCitizens;
    
    // declare a mapping that contains many instances of Citizen as a key we need to use something that is specific 
    // to the singular citizen so we can use either the citizenAddress or the fiscalCode (start with citizenAddress)
    // and see it everything works
    // this mapping will be called citizens
    mapping(address => Citizen) citizens;
    
    // create a struct where to store data regarding the individual citizens
    struct Citizen {
        
        address citizenAddress; // the ethereum address of the citizen, uniquely identifies a citizen
    
        string fiscalCode; // this variable can also uniquely identify each citizen
                           // maybe its better to use bytes32 data type for this variable. 
            
        bool paidDeposit; // we can add a check to make sure the citizen paid the deposit during the current year
        
        int taxesDue; // the amount of taxes the citizen needs to pay to the Municipality
                      // since each citizen pays an initial deposit this number can also be negative 
                      
        uint totalRecyclableWaste; // keep track of the recycable waste produced the particular citizen
        uint totalNonRecyclableWaste; // keep track of the unrecycable waste produced the particular citizen
    }
    
    //modifiers to limit function calls [address(0) is the default value of the mapping, by checking like below, we see if the account already exists]
    modifier isntCitizenYet(address _address){require(citizens[_address].citizenAddress == address(0)); _;} //cannot create 2 accounts
    modifier isCitizenCanPay(address _address){require(citizens[_address].citizenAddress != address(0) && citizens[_address].paidDeposit == false); _;} //can pay only if citizen and not already paid
 
    // create a function to instantiate citizens and add them to the citizens mapping
    // it will be external so that it can be called from outside this contract
    // WARNING: make sure each address can only call this function once
    function addCitizen(string calldata _fiscalCode) external isntCitizenYet(msg.sender){
        
        // create an instance of Citizen 
        // pass the variables explicitely
        Citizen memory citizen = Citizen({
            citizenAddress: msg.sender, // the address calling this function will be saved as the citizenAddress
            fiscalCode: _fiscalCode, // set the fiscalCode to the one provided by the citizen
            paidDeposit: false, // initially set the paidDeposit variable to false
            taxesDue: 0, // initially set taxesDue to 0
            totalRecyclableWaste: 0, 
            totalNonRecyclableWaste: 0
        });
        
        // add the instance of Citizen we just created to the mapping containing all the instances of citizens that is saved 
        // on the blockchain.
        // as the key of the mapping we use the citizenAddress variable of the specific citizen and 
        // the value associated with it is the instance itself of the Citizen struct we just created
        citizens[citizen.citizenAddress] = citizen;
    }
    
    // create a function that can be called by individual citizen in order to pay the initial deposit. 
    // to do so, it will need to be external and payable
    // the amount will be sent to this contract that is owned by the municipality
    // {potentially expand it so that one citizen can pay the deposit of another citizen}
    function payDeposit() external payable isCitizenCanPay(msg.sender){
        // make sure that the amount sent using this function is at least equal to the deposit required (1/10 ETH)
        // otherwise revert the transaction
        // the value sent can be accessed using msg.value
        if(msg.value >= deposit){
            // change the paidDeposit variable of the citizen who paid the deposit to true
            citizens[msg.sender].paidDeposit = true;
        } else {
            // revert the transaction
            revert();
        }
            
    }
    
    // create a function that modify the totalRecyclableWaste associate with a citizen
    // since totalRecyclableWaste directly affect the taxes that a citizen will pay,
    // only the owner of this contract (the municipality) should be able to call it
    // to achieve this we can use the onlyOwner modifier present in Ownable
    function _addRecyclableWaste () private onlyOwner {
        
    }
    
    // create a function that returns the total amount of money sent to this contract by a citizen
    // since it does not modify the data it will be a view function
    function getTotalTaxesPaid() external view returns(uint) {
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
    
    // get the fiscal code
    // function getFiscalCode() external view returns(string) {
    //     return citizens[msg.sender].fiscalCode;
    // }
    
    
    // create a function that can be executed only by the owner of the contract (the unicipality itself in our case)
    // at the end of the year that sets the paidDeposit field for every citizen to false
pragma solidity ^0.5.0; //whatever

/*
Possible basic implementation which heavily suffers from scalability problems since this
is tracking the single trashbag (would problems arise even if it were a trashbin?)
*/

contract TrashChain{

    address owner; //someone that could in the furutre trash the contract (see the pun?)
    uint public idCount; //placeholder for giving an id to the trashbags
    mapping(uint => TBag) public tbags; //maps id to trashbag

    enum State{ToPickUp, PickedUp, Deposited} //lifecycle of the trash bag

    struct TBag{
        uint id;  // unique identifier 
        uint type; // could be bool for just recyclable/not reciclable
        uint weight; //weight could be uint8 or less
        State state;
        address generator; // household that generated it (ethereum address)
        address transporter; // dumpster truck id ? (ethereum address)
        address recyclePlant; // end of the lifecycle for the trash bag (ethereum address)
    }

    //events for each possible state (to communicate outside the chain)
    //takes as input the identifier
    event ToPickUp(uint id);
    event PickedUp(uint id);
    event Deposited(uint id);

    //modifiers for owner and status of trashbag (notice the lower case compared to the events&states)
    modifier isOwner(){require(msg.sender == owner); _;}
    modifier toPickUp(uint _id){require(tbags[_id].state == State.ToPickUp); _;}
    modifier pickedUP(uint _id){require(tbags[_id].state == State.PickedUp); _;}
    //modifier deposited(uint _id){require(tbags[_id].state == State.Deposited); _;} //no need yet

    //the one who deploys the contract is the owner and the initial id count is set to 0
    //can just import Ownable from OpenZeppelin and use that one. But contract still in beta
    constructor() public {
        owner = msg.sender;
        idCount = 0;
    }
    function kill() public { 
        if(msg.sender == owner){selfdestruct(owner)}
    }

    /*
    Functions for the lifecycle of the trashbags
    generation: input type and weight(pick up from sensors?), automatic id (id), 
                State is at the first stage 'ToPickUp', generator is the person who calls the function,
                transporter and recycle plant are not yet known
    pick up bag: dump truck picks up the bag (via scan ?), and the state of the trashbag is changed 'PickedUp'
    drop at plant: trashbag gets dropped at the recycle plant and it enters the last stage 
    */
    function generateTbag(uint _type, uint _weight) public {
        emit ToPickUp(idCount); //tell the world or whoever listens
        tbags[idCount] = TBag({id: idCount, type = _type, weight = _weight, State = ToPickUp, generator = msg.sender, transporter = 0, recyclePlant = 0})
        idCount = idCount++;
    }
    function pickFromBin(uint id) public toPickUp(id){ //modifier to see if state is correct
        tbags[id].transporter = msg.sender;
        tbags[id].state = State.PickedUp;
        emit PickedUp(id);
    }
    function dropAtPlant(uint id) public pickedUP(id){ //modifier to see if state is correct
        tbags[id].recyclePlant = msg.sender;
        tbags[id].state = State.Deposited;
        emit Deposited(id);
    }
    //get info on a certain bag
    function fetchBag(uint _id) external view returns(uint id, uint type, uint weight, uint state, address generator, address transporter, address plant){
        id = tbags[_id].id;
        type = tbags[_id].type;
        weight = tbags[_id].weight;
        state = uint(tbags[_id].state);
        generator = tbags[_id].generator;
        transporter = tbags[_id].transporter;
        plant = tbags[_id].recyclePlant;
        return(id, type, weight, state, generator, transporter, plant)
    }
}
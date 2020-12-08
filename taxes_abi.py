abi = """
[
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_newGarbageCollector",
				"type": "address"
			}
		],
		"name": "_addGarbageCollectorRole",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_newMunicipalityManager",
				"type": "address"
			}
		],
		"name": "_addMunicipalityManager",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_oldCitizen",
				"type": "address"
			}
		],
		"name": "_removeCitizenRole",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_oldGarbageCollector",
				"type": "address"
			}
		],
		"name": "_removeGarbageCollectorRole",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_oldMunicipalityManagers",
				"type": "address"
			}
		],
		"name": "_removeMunicipalityManagers",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "addCitizen",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "generateTrashBag",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "transporter",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "disposalPlant",
				"type": "address"
			}
		],
		"name": "Deposited",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "previousOwner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "OwnershipTransferred",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "payDeposit",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "address",
				"name": "generator",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "transporter",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "pickUpTime",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "wasteWeight",
				"type": "uint256"
			},
			{
				"indexed": false,
				"internalType": "enum MunicipalityWasteTaxesRBAC.WasteType",
				"name": "wasteType",
				"type": "uint8"
			}
		],
		"name": "PickedUp",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_generator",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "_wasteWeight",
				"type": "uint256"
			},
			{
				"internalType": "enum MunicipalityWasteTaxesRBAC.WasteType",
				"name": "_wasteType",
				"type": "uint8"
			}
		],
		"name": "pickFromBin",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "renounceOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "bytes32",
				"name": "bagId",
				"type": "bytes32"
			},
			{
				"indexed": false,
				"internalType": "address",
				"name": "generator",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "generationTime",
				"type": "uint256"
			}
		],
		"name": "ToPickUp",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "transferOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "didIPayDeposit",
		"outputs": [
			{
				"internalType": "bool",
				"name": "",
				"type": "bool"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getAmountNonRecyclableWaste",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getAmountRecyclableWaste",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getTaxesDue",
		"outputs": [
			{
				"internalType": "int256",
				"name": "",
				"type": "int256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getTotalTaxesPaid",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]
"""



	


bytecode = "60806040523480156200001157600080fd5b50600062000024620000e360201b60201c565b9050806000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055508073ffffffffffffffffffffffffffffffffffffffff16600073ffffffffffffffffffffffffffffffffffffffff167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a350620000dd336003620000eb60201b6200161c1790919060201c565b62000234565b600033905090565b600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff1614156200012657600080fd5b620001388282620001a160201b60201c565b156200014357600080fd5b60018260000160008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548160ff0219169083151502179055505050565b60008073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff161415620001dd57600080fd5b8260000160008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900460ff16905092915050565b6118e080620002446000396000f3fe6080604052600436106100fe5760003560e01c80637456b81f11610095578063b94dee2911610064578063b94dee29146103fd578063bb0e510714610414578063e83c773f1461043f578063eee40abd1461046a578063f2fde38b14610481576100fe565b80637456b81f146102d95780638da5cb5b1461032a5780639428dfaa14610381578063b72f8dba146103d2576100fe565b80633a157af8116100d15780633a157af8146102165780635c274b86146102675780636c8966b714610271578063715018a6146102c2576100fe565b80630b3b35c9146101035780631e24fc1f1461015457806329039967146101835780633016827a146101ae575b600080fd5b34801561010f57600080fd5b506101526004803603602081101561012657600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff1690602001909291905050506104d2565b005b34801561016057600080fd5b50610169610559565b604051808215151515815260200191505060405180910390f35b34801561018f57600080fd5b506101986105b0565b6040518082815260200191505060405180910390f35b3480156101ba57600080fd5b50610214600480360360608110156101d157600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff16906020019092919080359060200190929190803560ff169060200190929190505050610628565b005b34801561022257600080fd5b506102656004803603602081101561023957600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190505050610886565b005b61026f61090d565b005b34801561027d57600080fd5b506102c06004803603602081101561029457600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190505050610aeb565b005b3480156102ce57600080fd5b506102d7610b72565b005b3480156102e557600080fd5b50610328600480360360208110156102fc57600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190505050610cfa565b005b34801561033657600080fd5b5061033f610d81565b604051808273ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200191505060405180910390f35b34801561038d57600080fd5b506103d0600480360360208110156103a457600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190505050610daa565b005b3480156103de57600080fd5b506103e7610e31565b6040518082815260200191505060405180910390f35b34801561040957600080fd5b50610412610e7b565b005b34801561042057600080fd5b50610429610fd3565b6040518082815260200191505060405180910390f35b34801561044b57600080fd5b5061045461101d565b6040518082815260200191505060405180910390f35b34801561047657600080fd5b5061047f611067565b005b34801561048d57600080fd5b506104d0600480360360208110156104a457600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff16906020019092919050505061124a565b005b600115156104ea33600361145790919063ffffffff16565b151514610542576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252602e81526020018061180c602e913960400191505060405180910390fd5b6105568160016114e990919063ffffffff16565b50565b6000600460003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060000160009054906101000a900460ff16905090565b6000600115156105ca33600361145790919063ffffffff16565b151514610622576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252602e81526020018061180c602e913960400191505060405180910390fd5b47905090565b6001151561064033600261145790919063ffffffff16565b151514610698576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252602e8152602001806117de602e913960400191505060405180910390fd5b6000806000859250849150839050600060048111156106b357fe5b8160048111156106bf57fe5b14156107705781600460008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206003016000828254019250508190555061076a82600460008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206003015461159490919063ffffffff16565b506107c1565b81600460008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020600201600082825401925050819055505b7fe54817d822d5ace9031813073cb75f8de6dc2fa11e538745cff9a1a8f864b2878633428888604051808673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020018573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200184815260200183815260200182600481111561086757fe5b60ff1681526020019550505050505060405180910390a1505050505050565b6001151561089e33600361145790919063ffffffff16565b1515146108f6576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252602e81526020018061180c602e913960400191505060405180910390fd5b61090a81600261161c90919063ffffffff16565b50565b60001515600460003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060000160009054906101000a900460ff161515146109b9576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252603481526020018061183a6034913960400191505060405180910390fd5b67016345785d8a00003410610a98576001600460003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060000160006101000a81548160ff0219169083151502179055507ffffffffffffffffffffffffffffffffffffffffffffffffffe9cba87a2760000600460003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060010160008282540192505081905550610ae9565b6040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252603d81526020018061186e603d913960400191505060405180910390fd5b565b60011515610b0333600361145790919063ffffffff16565b151514610b5b576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252602e81526020018061180c602e913960400191505060405180910390fd5b610b6f8160036114e990919063ffffffff16565b50565b610b7a6116c8565b73ffffffffffffffffffffffffffffffffffffffff166000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1614610c3b576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260208152602001807f4f776e61626c653a2063616c6c6572206973206e6f7420746865206f776e657281525060200191505060405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff166000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a360008060006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550565b60011515610d1233600361145790919063ffffffff16565b151514610d6a576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252602e81526020018061180c602e913960400191505060405180910390fd5b610d7e81600361161c90919063ffffffff16565b50565b60008060009054906101000a900473ffffffffffffffffffffffffffffffffffffffff16905090565b60011515610dc233600361145790919063ffffffff16565b151514610e1a576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252602e81526020018061180c602e913960400191505060405180910390fd5b610e2e8160026114e990919063ffffffff16565b50565b6000600460003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060020154905090565b60001515600460003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060050160009054906101000a900460ff16151514610edb57600080fd5b610ee3611758565b6040518060c001604052806000151581526020016000815260200160008152602001600081526020016000815260200160011515815250905080600460003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008201518160000160006101000a81548160ff0219169083151502179055506020820151816001015560408201518160020155606082015181600301556080820151816004015560a08201518160050160006101000a81548160ff021916908315150217905550905050610fd0336116d0565b50565b6000600460003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060030154905090565b6000600460003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060010154905090565b6001151561107f33600161145790919063ffffffff16565b1515146110d7576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260258152602001806117b96025913960400191505060405180910390fd5b60011515600460003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060000160009054906101000a900460ff16151514611183576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252603481526020018061183a6034913960400191505060405180910390fd5b60006111d23342600460003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020600401546116e7565b90507fbbdd848711604cf3f095b973f631607b7aea61e0ae295f5afd37910a64afddd1813342604051808481526020018373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001828152602001935050505060405180910390a150565b6112526116c8565b73ffffffffffffffffffffffffffffffffffffffff166000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1614611313576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260208152602001807f4f776e61626c653a2063616c6c6572206973206e6f7420746865206f776e657281525060200191505060405180910390fd5b600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff161415611399576040517f08c379a00000000000000000000000000000000000000000000000000000000081526004018080602001828103825260268152602001806117936026913960400191505060405180910390fd5b8073ffffffffffffffffffffffffffffffffffffffff166000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff167f8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e060405160405180910390a3806000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff16021790555050565b60008073ffffffffffffffffffffffffffffffffffffffff168273ffffffffffffffffffffffffffffffffffffffff16141561149257600080fd5b8260000160008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060009054906101000a900460ff16905092915050565b600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16141561152357600080fd5b61152d8282611457565b61153657600080fd5b60008260000160008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548160ff0219169083151502179055505050565b600080828401905083811015611612576040517f08c379a000000000000000000000000000000000000000000000000000000000815260040180806020018281038252601b8152602001807f536166654d6174683a206164646974696f6e206f766572666c6f77000000000081525060200191505060405180910390fd5b8091505092915050565b600073ffffffffffffffffffffffffffffffffffffffff168173ffffffffffffffffffffffffffffffffffffffff16141561165657600080fd5b6116608282611457565b1561166a57600080fd5b60018260000160008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060006101000a81548160ff0219169083151502179055505050565b600033905090565b6116e481600161161c90919063ffffffff16565b50565b6000838383604051602001808473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1660601b815260140183815260200182815260200193505050506040516020818303038152906040528051906020012090509392505050565b6040518060c0016040528060001515815260200160008152602001600081526020016000815260200160008152602001600015158152509056fe4f776e61626c653a206e6577206f776e657220697320746865207a65726f20616464726573734d75737420686176652074686520636974697a656e526f6c65207065726d697373696f6e214d7573742068617665207468652067617262616765436f6c6c6563746f72526f6c65207065726d697373696f6e214d757374206861766520746865206d756e69636970616c6974794d616e6167657273207065726d697373696f6e21596f75206861766520746f2070617920746865206465706f736974206265666f726520796f752063616e20636f6e74696e75652154686520616d6f756e7420796f75206172652073656e64696e67206973206e6f7420656e6f75676820746f20636f76657220746865206465706f736974a264697066735822122001ee5f47ee38edb61b71f728c47194d366a0c7e51d034c7805e35dbf53d7732164736f6c63430006000033"
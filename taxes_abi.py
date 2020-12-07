abi = """[
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
		"name": "generateTrashBag",
		"outputs": [],
		"stateMutability": "nonpayable",
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
	},
	{
		"inputs": [],
		"name": "payDeposit",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
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
	}
]"""
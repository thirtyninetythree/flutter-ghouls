import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;

class NFT {
  String tokenID;
  String symbol;
  String collectionName;
  String image;

  NFT({
    required this.tokenID,
    required this.symbol,
    required this.collectionName,
    required this.image,
  });

  static NFT fromMap(map) {
    // print("map['name'] = ${map["name"]}");
    return NFT(
      tokenID: map["tokenID"].toString(),
      symbol: map["symbol"],
      collectionName: map["name"],
      image: map["image"],
    );
  }
}

const String MORALIS_API_KEY = "";
const String NFT_STORAGE_KEY = "";
const String RINKEBY_NFT_ADDRESS = "";

const String TEST_FTM_NFT = "";
const int CHAIN_ID = 4; //002; //ftm-testnet
const String rinkeby_rpc_url = "";
const String rinkeby_ws_url = "";
const String contractName = "";
const String newFileName = "";

class BlockchainProvider with ChangeNotifier {
  final DeployedContract contract = DeployedContract(
      ContractAbi.fromJson(ABI, contractName),
      EthereumAddress.fromHex(RINKEBY_NFT_ADDRESS));

  static Credentials _credentials = EthPrivateKey.fromHex("");
  static final client =
      Web3Client(rinkeby_rpc_url, Client(), socketConnector: () {
    return IOWebSocketChannel.connect(rinkeby_ws_url).cast<String>();
  });
  // ignore: prefer_final_fields
  List<NFT> _nfts = [];
  List<NFT> get nfts => _nfts;
  int _numberOfNFTsOwned = 0;
  int get numberOfNFTsOwned => _numberOfNFTsOwned;

  EthereumAddress? _address;

  EthereumAddress? get address => _address;

  EtherAmount _balance = EtherAmount.zero();
  EtherAmount get balance => _balance;

  final _nftStorageUploadURL = Uri.parse("https://api.nft.storage/upload");

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File("$path/wallet.json");
  }

  //only ever called once
  void generateNewWallet() async {
    var rng = Random.secure();
    Wallet newWallet =
        Wallet.createNew(EthPrivateKey.createRandom(rng), "test", rng);

    //store them
    final file = await _localFile;
    file.writeAsStringSync(newWallet.toJson());

    _credentials = newWallet.privateKey;
    _address = await _credentials.extractAddress();
    print("new wallet $_address generated");

    final SharedPreferences prefs = await _prefs;
    prefs.setBool("wallet", true);
  }

  void unlockWallet() async {
    final file = await _localFile;
    String content = file.readAsStringSync();
    Wallet wallet = Wallet.fromJson(content, "test");

    _credentials = wallet.privateKey;
    _address = await _credentials.extractAddress();
    print("wallet $_address unlocked");
// You can now use these credentials to sign transactions or messages
  }

  Future<File> changeFileNameOnly(File file, String newFileName) {
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    return file.rename(newPath);
  }

  Future<String> uploadNFT(String filepath) async {
    print("### uploadNFT ###");
    var request = http.MultipartRequest("POST", _nftStorageUploadURL);
    request.headers["Authorization"] = "Bearer $NFT_STORAGE_KEY";
    File newFile = await changeFileNameOnly(File(filepath), "$newFileName.jpg");
    request.files.add(await http.MultipartFile.fromPath("file", newFile.path));

    var response = await request.send();
    if (response.statusCode == 200) print("Uploaded");
    final respStr = await response.stream.bytesToString();
    final cid = jsonDecode(respStr)["value"]['cid'];

    return cid;
  }

  Future<String> uploadMetadata(String nftCID) async {
    final metadata = {
      "Ghouls Collection": {
        "tokenID": _numberOfNFTsOwned, //call supply
        "name": "Collection #$numberOfNFTsOwned", //function
        "symbol": "GHOUL",
        "image": "https://ipfs.io/ipfs/$nftCID/ghoul.jpg",
      }
    };
    final response = await http.post(_nftStorageUploadURL,
        body: jsonEncode(metadata),
        headers: {"Authorization": "Bearer $NFT_STORAGE_KEY"});
    final cid = jsonDecode(response.body)["value"]["cid"];
    return cid;
  }

  Future mint(String filepath) async {
    if (_balance == EtherAmount.zero()) return "insufficient ether balance";
    try {
      final to = await _credentials.extractAddress();
      final nftCID = await uploadNFT(filepath);
      final tokenURI = await uploadMetadata(nftCID);

      await client.sendTransaction(
          _credentials,
          Transaction.callContract(
            contract: contract,
            function: contract.function("safeMint"),
            parameters: [to, tokenURI],
          ),
          chainId: CHAIN_ID);
      client.dispose();
    } catch (e) {
      return "error $e";
    }
    return "successfully minted: ";
  }

  Future fetchNFTs() async {
    try {
      _balance = await getBalance();

      var uri = Uri.parse(
          "https://deep-index.moralis.io/api/v2/$_address/nft/$RINKEBY_NFT_ADDRESS?chain=rinkeby&format=decimal");

      final response =
          await http.get(uri, headers: {"X-API-Key": MORALIS_API_KEY});

      final snapshot = jsonDecode(response.body)["result"];

      // final metadata = jsonDecode(snapshot[0]["metadata"])["Ghouls Collection"];
      _nfts = List.generate(
          snapshot.length,
          (int index) => NFT.fromMap(
              jsonDecode(snapshot[index]["metadata"])["Ghouls Collection"]));
    } catch (e) {}
    return _nfts;
  }

  fetchMetadata(String tokenURI) async {
    final res = await http.get(Uri.parse(tokenURI));
    return res.body;
  }

  Future<EtherAmount> getBalance() async {
    return await client.getBalance(await _credentials.extractAddress());
  }
}

const ABI = '''[
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "approved",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "Approval",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "operator",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "bool",
				"name": "approved",
				"type": "bool"
			}
		],
		"name": "ApprovalForAll",
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
				"indexed": true,
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "Transfer",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "approve",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			}
		],
		"name": "balanceOf",
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
		"inputs": [
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "getApproved",
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
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "operator",
				"type": "address"
			}
		],
		"name": "isApprovedForAll",
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
		"name": "name",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
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
		"inputs": [
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "ownerOf",
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
		"name": "renounceOwnership",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "uri",
				"type": "string"
			}
		],
		"name": "safeMint",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "safeTransferFrom",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			},
			{
				"internalType": "bytes",
				"name": "_data",
				"type": "bytes"
			}
		],
		"name": "safeTransferFrom",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "operator",
				"type": "address"
			},
			{
				"internalType": "bool",
				"name": "approved",
				"type": "bool"
			}
		],
		"name": "setApprovalForAll",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes4",
				"name": "interfaceId",
				"type": "bytes4"
			}
		],
		"name": "supportsInterface",
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
		"name": "symbol",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "tokenByIndex",
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
		"inputs": [
			{
				"internalType": "address",
				"name": "owner",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "tokenOfOwnerByIndex",
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
		"inputs": [
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "tokenURI",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "totalSupply",
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
		"inputs": [
			{
				"internalType": "address",
				"name": "from",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "to",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "tokenId",
				"type": "uint256"
			}
		],
		"name": "transferFrom",
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
]''';

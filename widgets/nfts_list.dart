import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ghouls/widgets/nft_card.dart';
import 'package:ghouls/widgets/wallet_header.dart';

import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

import '../providers/nft_metadata.dart';

class NFTListPage extends StatefulWidget {
  const NFTListPage({Key? key}) : super(key: key);

  @override
  _NFTListPageState createState() => _NFTListPageState();
}

class _NFTListPageState extends State<NFTListPage> {
  late EtherAmount balance;
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BlockchainProvider>(context, listen: false);
    provider.fetchNFTs();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BlockchainProvider>(builder: (context, block, child) {
      return FutureBuilder(
          future: block.fetchNFTs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                        child: WalletHeader(
                            address: block.address,
                            balance: block.balance,
                            numberOfNftsOwned: block.numberOfNFTsOwned),
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: block.address!.hex));
                          final snackBar = SnackBar(
                            content: Text("Copied: ${block.address!.hex}"),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }),
                  ),
                  Expanded(
                    flex: 7,
                    child: block.nfts.length == 0
                        ? Center(
                            child: Text(
                                "QUICKLY MINT A NEW NFT TO FILL THIS EMPTY SPACE!!!"),
                          )
                        : ListView.builder(
                            itemCount: block.nfts.length,
                            itemBuilder: (context, int index) {
                              return NFTCard(
                                nft: block.nfts[index],
                              );
                            }),
                  ),
                ],
              );
            } else if (snapshot.hasError || !snapshot.hasData) {
              return Text("OOPS ERROR HAS OCCURRED ${snapshot.error}");
            }
            return const Center(child: CircularProgressIndicator());
          });
    });
  }
}

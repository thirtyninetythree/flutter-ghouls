import 'package:flutter/material.dart';
import 'package:ghouls/providers/nft_metadata.dart';

class NFTCard extends StatelessWidget {
  const NFTCard({Key? key, required this.nft}) : super(key: key);

  final NFT nft;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              nft.image,
              scale: .8,
              loadingBuilder: ((context, child, loadingProgress) {
                return loadingProgress == null
                    ? child
                    : Center(
                        child: Container(
                            margin: const EdgeInsets.all(16.0),
                            padding: const EdgeInsets.all(16.0),
                            child: const CircularProgressIndicator()));
              }),
              errorBuilder: ((context, error, stackTrace) => Container(
                  padding: const EdgeInsets.all(16.0),
                  height: 200,
                  child: const Center(
                      child: Text("NFT eaten by the blockchain!")))),
            ),
            const Divider(
              thickness: 2.0,
              height: 2.0,
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Center(
                child: Text(
              "name Of Collection",
              style: TextStyle(fontSize: 16.0, color: Colors.black87),
            )),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    nft.collectionName,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text("PRICE"),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("${nft.symbol} #${nft.tokenID}"),
                  const Text("NO OFFER")
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

class WalletHeader extends StatelessWidget {
  final EthereumAddress? address;
  final EtherAmount balance;
  final int? numberOfNftsOwned;
  const WalletHeader(
      {Key? key,
      required this.address,
      required this.balance,
      required this.numberOfNftsOwned})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: const Text("Your Wallet",
              style:
                  const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            width: size.width * .9,
            height: size.height * .4,
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                boxShadow: customShadow,
                borderRadius: BorderRadius.circular(20.0)),
            child: Stack(
              children: [
                Positioned.fill(
                    left: -300,
                    top: -100,
                    bottom: -100,
                    child: Container(
                      decoration: BoxDecoration(
                          boxShadow: customShadow,
                          shape: BoxShape.circle,
                          color: Colors.white38),
                    )),
                Positioned(
                  top: -40.0,
                  right: -20.0,
                  child: SizedBox(
                      width: size.width * .5,
                      height: 150,
                      child: Image.asset("assetNameHere")),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0, left: 18.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address!.hex,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "${balance.getInEther}  Ether",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "$numberOfNftsOwned NFTs",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w100),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

List<BoxShadow> customShadow = [
  BoxShadow(
      color: Colors.white.withOpacity(.5),
      spreadRadius: -5,
      offset: const Offset(-5, -5),
      blurRadius: 30),
  BoxShadow(
      color: Colors.blue[200]!.withOpacity(.2),
      spreadRadius: 2,
      offset: const Offset(7, 7),
      blurRadius: 20)
];

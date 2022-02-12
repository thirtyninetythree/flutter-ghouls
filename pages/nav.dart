import 'package:flutter/material.dart';
import 'package:ghouls/pages/onboarding_page.dart';
import 'package:ghouls/widgets/nft_picker_page.dart';

import 'package:provider/provider.dart';

import 'package:ghouls/providers/nft_metadata.dart';
import 'package:ghouls/widgets/nfts_list.dart';

import '../widgets/pixel_border.dart';

class Nav extends StatefulWidget {
  const Nav({Key? key}) : super(key: key);
  static const String routeName = "/nav";

  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const NFTListPage(),
    const NFTPickerPage(),
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<BlockchainProvider>(context, listen: false);
    provider.unlockWallet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: PixelBorder.shape(
          borderRadius: BorderRadius.circular(15.0),
          pixelSize: 5.0,
        ),
        title: const Text(
          "ghouls 👻",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () => _onItemTap(0),
                child: Text(
                  "HOME",
                  style: TextStyle(
                    fontSize: _selectedIndex == 0 ? 24.0 : 20.0,
                  ),
                )),
            ElevatedButton(
              onPressed: () => _onItemTap(1),
              child: Text(
                "MINT",
                style: TextStyle(
                  fontSize: _selectedIndex == 1 ? 24.0 : 20.0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

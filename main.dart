import 'package:flutter/material.dart';
import 'package:ghouls/pages/nav.dart';
import 'package:ghouls/pages/onboarding_page.dart';
import 'package:ghouls/widgets/pixel_border.dart';

import 'package:provider/provider.dart';

import 'package:ghouls/providers/nft_metadata.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => BlockchainProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<bool> checkWalletExists() async {
    final SharedPreferences prefs = await _prefs;
    bool? walletExists = prefs.getBool('wallet');
    if (walletExists == null) return false;
    return true;
  }

  bool walletExists = false;

  @override
  void initState() {
    super.initState();
    run() async => walletExists = await checkWalletExists();
    run();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ghouls',
      theme: ThemeData(
          primaryColor: const Color(0xFFCADCED),
          fontFamily: "Circular",
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                  elevation: MaterialStateProperty.all(5.0),
                  backgroundColor: MaterialStateProperty.all(Colors.black),
                  shape: MaterialStateProperty.all(
                    PixelBorder.shape(
                      borderRadius: BorderRadius.circular(10.0),
                      pixelSize: 5.0,
                    ),
                  )))),
      debugShowCheckedModeBanner: false,
      home: walletExists ? Nav() : OnboardingPage(),
      routes: {
        Nav.routeName: (context) => Nav(),
        OnboardingPage.routeName: (context) => OnboardingPage(),
      },
    );
  }
}

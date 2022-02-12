import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ghouls/pages/nav.dart';
import 'package:ghouls/providers/nft_metadata.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  static const routeName = "/onboarding";

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
            title: "Mint NFTs directly from your phone",
            body: "WELCOME",
            image: SvgPicture.asset("assets/images/welcome.svg",
                semanticsLabel: 'welcome image')),
        PageViewModel(
          title: "Check your wallet balance and number fo NFTs in your wallet",
          body: "Details, details, details",
          image: SvgPicture.asset("assets/images/details.svg",
              semanticsLabel: 'details image'),
        ),
        PageViewModel(
            title:
                "With great power comes great responsibility to mint nfts. Are you ready?",
            bodyWidget: Center(
              child: ElevatedButton(
                child: Text("GENERATE MY NEW WALLET"),
                onPressed: () {
                  Provider.of<BlockchainProvider>(context, listen: false)
                      .generateNewWallet();
                  Navigator.of(context).pushReplacementNamed(Nav.routeName);
                },
              ),
            ),
            image: SvgPicture.asset("assets/images/uponly.svg",
                semanticsLabel: 'details image'))
      ],
      // onDone: () {
      //   Provider.of<BlockchainProvider>(context, listen: false)
      //       .generateNewWallet();
      //   Navigator.of(context).pushReplacementNamed(Nav.routeName);
      // },

      showDoneButton: false,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      // done: const Text("GENERATE MY NEW WALLET"),
      curve: Curves.fastLinearToSlowEaseIn,
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Colors.blueGrey,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
    );
  }
}

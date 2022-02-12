import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ghouls/providers/nft_metadata.dart';
import 'package:ghouls/widgets/pixel_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class NFTPickerPage extends StatefulWidget {
  const NFTPickerPage({Key? key}) : super(key: key);

  @override
  _NFTPickerPageState createState() => _NFTPickerPageState();
}

class _NFTPickerPageState extends State<NFTPickerPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? image;
  void getImageFromGallery() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = XFile(selectedImage!.path);
    });
  }

  void getImageFromCamera() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      image = XFile(selectedImage!.path);
    });
  }

  void removeCurrentImage() {
    setState(() {
      image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BlockchainProvider>(context, listen: false);
    return Center(
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: const Text("Gallery"),
                onPressed: getImageFromGallery,
              ),
              ElevatedButton(
                child: const Text("Take Photo"),
                onPressed: getImageFromCamera,
              ),
              if (image != null)
                ElevatedButton(
                  child: const Text("Remove"),
                  onPressed: removeCurrentImage,
                ),
            ],
          ),
          image == null
              ? const Center(child: Text("Pick an image"))
              //make it tappable to show large preview preview
              : Card(
                  elevation: 5,
                  shape: PixelBorder.shape(
                    borderRadius: BorderRadius.circular(10.0),
                    pixelSize: 5.0,
                  ),
                  margin: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Image.file(File(image!.path)),
                  )),
          if (image != null)
            SizedBox(
              width: 100,
              child: ElevatedButton(
                child: const Text("MINT"),
                onPressed: () async {
                  String message = await provider.mint(image!.path);
                  final snackBar = SnackBar(
                    content: Text(message),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
              ),
            ),
        ],
      ),
    );
  }
}

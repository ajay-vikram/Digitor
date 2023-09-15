import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:digit_app/dl_model/classifier.dart';
import 'dart:io';

class UploadImage extends StatefulWidget {
  const UploadImage({Key? key}) : super(key: key);

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  XFile? selectedImage;
  Classifier classifier = Classifier();
  int digit = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: Icon(Icons.camera_alt_outlined),
        onPressed: () async {
          final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
          if(pickedFile != null) {
            digit = await classifier.classifyImage(PickedFile(pickedFile.path));
          }

          setState(() {
            selectedImage = pickedFile != null ? XFile(pickedFile.path) : null;
          });
        },
      ),
      appBar: AppBar(backgroundColor:  Colors.blue, title: Text("Digit Recognizer"),),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 40,),
            Text("Image will be shown below", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10, ),
            Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2.0),
                image: selectedImage != null
                    ? DecorationImage(
                  image: FileImage(File(selectedImage!.path)),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
            ),
            SizedBox(height: 45,),
            Text("Current Prediction:", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            SizedBox(height: 20,),
            Text(digit == -1 ? "" : "$digit", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),)
          ]
        ),
      ),
    );
  }
}

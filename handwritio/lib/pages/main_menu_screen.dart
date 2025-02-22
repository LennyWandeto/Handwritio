import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'dart:convert';

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  final String _serverUrl = "http://127.0.0.1:5000/upload"; // Backend URL

  String _extractedText = ""; // Stores the extracted text

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // Send image to the backend and get text
      await _uploadImage(_image!);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    var request = http.MultipartRequest("POST", Uri.parse(_serverUrl));
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      contentType: MediaType.parse(lookupMimeType(imageFile.path) ?? 'image/jpeg'),
    ));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      setState(() {
        _extractedText = jsonResponse["text"];
      });
    } else {
      print("Upload failed: ${response.reasonPhrase}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Handwritio - Main Menu")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null) 
              Image.file(_image!, height: 300),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.camera),
              label: Text("Capture Image"),
            ),
            SizedBox(height: 20),
            Text(
              "Extracted Text: \n$_extractedText",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

// Data Model
class ExtractedData {
  final List<File> images;
  final String text;
  ExtractedData({required this.images, required this.text});
}
 
// Main App
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Handwritio',
      theme: ThemeData.dark(),
      home: AuthWrapper(),
    );
  }
}

// Authentication Wrapper
class AuthWrapper extends StatefulWidget {
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;
  late String _username;

  void _handleLogin(String username) {
    setState(() {
      _isLoggedIn = true;
      _username = username;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn 
        ? TabBarDemo(username: _username)
        : AnimatedWelcomePage(onLogin: _handleLogin);
  }
}

// Animated Welcome Page
class AnimatedWelcomePage extends StatefulWidget {
  final Function(String) onLogin;
  const AnimatedWelcomePage({required this.onLogin, super.key});

  @override
  State<AnimatedWelcomePage> createState() => _AnimatedWelcomePageState();
}

class _AnimatedWelcomePageState extends State<AnimatedWelcomePage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation, _textAnimation, _formAnimation;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ));

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.5, curve: Curves.easeIn),
    ));

    _formAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('background.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    "Welcome",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _textAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _textAnimation.value)),
                      child: const Text(
                        "You've made a big decision.\nNo more bad handwriting.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _formAnimation,
                  builder: (context, child) => Opacity(
                    opacity: _formAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _formAnimation.value)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                style: const TextStyle(color: Colors.black),
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                  border: OutlineInputBorder(),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                validator: (value) => 
                                  value?.isEmpty ?? true ? 'Required' : null,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ?? false) {
                                    widget.onLogin(_usernameController.text);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[700],
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Submit')),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Main Tab Navigation
class TabBarDemo extends StatelessWidget {
  final String username;
  const TabBarDemo({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Handwritio'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.camera)),
              Tab(icon: Icon(Icons.folder)),
              Tab(icon: Icon(Icons.account_circle)),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.jpeg'),
              fit: BoxFit.cover,
            ),
          ),
          child: TabBarView(
            children: [
              MainMenu(),
              const Center(child: Icon(Icons.photo_library, size: 100)),
              AccountPage(username: username),
            ],
          ),
        ),
      ),
    );
  }
}

// Main Camera Interface
class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  final String _serverUrl = "http://127.0.0.1:5000/upload";
  String _extractedText = "";
  List<ExtractedData> _savedDocuments = [];

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _images.add(File(pickedFile.path)));
      await _uploadImages();
    }
  }

  Future<void> _uploadImages() async {
    var request = http.MultipartRequest("POST", Uri.parse(_serverUrl));
    for (var image in _images) {
      request.files.add(await http.MultipartFile.fromPath(
        'images',
        image.path,
        contentType: MediaType.parse(lookupMimeType(image.path) ?? 'image/jpeg'),
      ));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      setState(() => _extractedText = jsonResponse["text"]);
    } else {
      print("Upload failed: ${response.reasonPhrase}");
    }
  }

  void _saveDocument() {
    if (_images.isNotEmpty && _extractedText.isNotEmpty) {
      final newDoc = ExtractedData(
        images: List<File>.from(_images),
        text: _extractedText,
      );
      setState(() {
        _savedDocuments.add(newDoc);
        _images.clear();
        _extractedText = "";
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(data: newDoc),
        ),
      );
    }
  }

  void _discardDocument() {
    setState(() {
      _images.clear();
      _extractedText = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                if (_images.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.file(_images[index], height: 180),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Extracted Text: \n$_extractedText",
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          if (_images.isNotEmpty)
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _saveDocument,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Save'),
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Add Another'),
                ),
                ElevatedButton(
                  onPressed: _discardDocument,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Discard'),
                ),
              ],
            ),
          Center(
            child: ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera),
              label: const Text("Start Capture"),
            ),
          ),
        ],
      ),
    );
  }
}

// Detail Screen
class DetailScreen extends StatefulWidget {
  final ExtractedData data;
  const DetailScreen({required this.data, Key? key}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detailed View"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.data.images.length,
                  onPageChanged: (int page) => setState(() => _currentPage = page),
                  itemBuilder: (context, index) => Image.file(
                    widget.data.images[index],
                    fit: BoxFit.contain,
                  ),
                ),
                if (widget.data.images.length > 1)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentPage + 1}/${widget.data.images.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Extracted Text:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Text(widget.data.text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Account Page
class AccountPage extends StatelessWidget {
  final String username;
  const AccountPage({required this.username, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Logged in as: $username', 
            style: const TextStyle(fontSize: 24, color: Colors.white)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
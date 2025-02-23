import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'package:handwritio/main.dart';
import 'take_photo.dart'


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
                  onPageChanged: (int page) {
                    setState(() => _currentPage = page);
                  },
                  itemBuilder: (context, index) {
                    return Hero(
                      tag: widget.data.images[index].path,
                      child: Image.file(
                        widget.data.images[index],
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
                if (widget.data.images.length > 1)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentPage + 1}/${widget.data.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16
                      ),
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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

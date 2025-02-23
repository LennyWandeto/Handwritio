/*

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:handwritio/detail_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'package:handwritio/main.dart';


// Updated ExtractedData class
class ExtractedData {
  final List<File> images;
  final String text;
  ExtractedData({required this.images, required this.text});
}

// Updated ExtractedDataCard
class ExtractedDataCard extends StatelessWidget {
  final ExtractedData data;

  const ExtractedDataCard({required this.data, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DetailScreen(data: data)),
      child: Card(
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Hero(
                    tag: data.images.first.path,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        data.images.first,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (data.images.length > 1)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '+${data.images.length - 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    )
                ],
              ),
              const SizedBox(height: 15),
              const Text(
                "Extracted Text:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                data.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ));
  }
  
}

*/
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:handwritio/take_photo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'dart:convert';
import 'package:handwritio/main.dart';
import 'detail_screen.dart';


class ExtractedDataCard extends StatelessWidget {
  final ExtractedData data;

  const ExtractedDataCard({required this.data, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(data: data),
        ),
      ),
      child: Card(
        margin: EdgeInsets.all(20),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Hero(
                tag: data.image.path,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    data.images,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Text(
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
    );
  }
}

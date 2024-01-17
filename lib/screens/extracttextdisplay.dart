import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_ml_kit/google_ml_kit.dart' as ml_kit;

import 'package:share/share.dart';

import 'Strartscreen.dart';

class ResultScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String imagePath = args['imagePath'];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(2, 179, 234, 1.0),
        title: Text(
          'Text Extracted',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyStartScreen(),
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.copy,
              color: Colors.white,
            ),
            onPressed: () => _copyToClipboard(context, imagePath),
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareText(context, imagePath),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: FutureBuilder<String>(
            future: _extractTextFromImage(imagePath),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      snapshot.data ?? 'No text found in the image',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.normal),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<String> _extractTextFromImage(String imagePath) async {
    try {
      final inputImage = ml_kit.InputImage.fromFile(File(imagePath));
      final textRecognizer = ml_kit.GoogleMlKit.vision.textRecognizer();
      final ml_kit.RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      String extractedText = '';

      for (ml_kit.TextBlock block in recognizedText.blocks) {
        for (ml_kit.TextLine line in block.lines) {
          extractedText += line.text + ' ';
        }
        extractedText += '\n';
      }

      extractedText = extractedText.replaceAll(RegExp(r'\s+'), ' ');

      return extractedText.isEmpty
          ? 'No text found in the image'
          : extractedText.trim();
    } catch (e) {
      print('Error extracting text: $e');
      return 'Error extracting text';
    }
  }

  Future<void> _copyToClipboard(BuildContext context, String imagePath) async {
    final String text = await _extractTextFromImage(imagePath);
    await FlutterClipboard.copy(text);
    Fluttertoast.showToast(
      msg: 'Text copied to clipboard: $text',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<void> _shareText(BuildContext context, String imagePath) async {
    final String text = await _extractTextFromImage(imagePath);
    Share.share(text, subject: 'Extracted Text');
  }
}

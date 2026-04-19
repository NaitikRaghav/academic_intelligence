import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class OCRService {
  // We initialize the recognizer for standard Latin script (English, Spanish, etc.)
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  /// 🔍 Extracts text from a handwritten or printed image file
  Future<String> extractTextFromImage(File imageFile) async {
    try {
      // 1. Convert the standard Dart File into ML Kit's specialized InputImage format
      final inputImage = InputImage.fromFile(imageFile);

      // 2. Process the image through the on-device machine learning model
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // 3. Reconstruct the text block by block to maintain paragraph structure
      StringBuffer extractedText = StringBuffer();
      
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          extractedText.writeln(line.text);
        }
        extractedText.writeln(); // Add a blank line between major blocks
      }

      return extractedText.toString().trim();
    } catch (e) {
      throw Exception('Failed to extract text from image: $e');
    }
  }

  /// 🧹 Always remember to close the recognizer to prevent memory leaks
  void dispose() {
    _textRecognizer.close();
  }
}
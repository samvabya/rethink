import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ImageGeneratorProvider extends ChangeNotifier {
  final ImageApi _ImageApi = ImageApi();
  
  Uint8List? _generatedImageBytes;
  bool _isLoading = false;
  String? _error;

  Uint8List? get generatedImageBytes => _generatedImageBytes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> generateImage(String prompt) async {
    if (prompt.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final imageBytes = await _ImageApi.generateImage(prompt);
      _generatedImageBytes = Uint8List.fromList(imageBytes);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _generatedImageBytes = null;
    _error = null;
    notifyListeners();
  }
}

class ImageApi {
  static const String baseUrl = 'https://api.vyro.ai/v2/image/generations';

  String apiKey = dotenv.env['IMAGE_API_KEY']!;

  Future<List<int>> generateImage(String prompt) async {
    try {
      var headers = {
        'Authorization':
            'Bearer $apiKey' // Use the constant instead of hardcoding
      };
      var request = http.MultipartRequest(
          'POST', Uri.parse(baseUrl)); // Use the constant instead of hardcoding
      request.fields.addAll({
        'prompt': prompt, // Use the parameter instead of hardcoded value
        'style': 'realistic',
        'aspect_ratio': '1:1',
        'seed': '5'
      });

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Return the bytes directly instead of converting to string
        final bytes = await response.stream.toBytes();
        return bytes;
      } else {
        log('Error: ${response.statusCode} ${response.reasonPhrase}');
        throw Exception('Failed to generate image: ${response.statusCode}');
      }
    } catch (e) {
      log('Error generating image: $e');
      throw Exception('Error generating image: $e');
    }
  }
}

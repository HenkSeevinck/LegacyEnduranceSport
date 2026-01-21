import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//----------------------------------------------------
// Provider class to get the available parks
class ImageVerificationProvider with ChangeNotifier {

  Map<String, dynamic> _workoutResult = {};
  Map<String, dynamic> get workoutResult => _workoutResult;

  Future<Map<String, dynamic>> verifyImage(Uint8List imageBytes) async {
    // Send image to n8n workflow for verification
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://n8n.seevinckserver.com/webhook/f47e8938-0231-4626-810a-3e0af9801f6b'),
    );
    request.headers.addAll({
      //'AnimalLogger': authorizationHeader, // Or 'Bearer your-token'
      'Accept': 'application/json',
    });

    request.files.add(
      http.MultipartFile.fromBytes('image', imageBytes, filename: 'image.jpg'),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      // Read raw bytes then decode to string to avoid charset/BOM issues
      final respBytes = await response.stream.toBytes();
      final responseBody = utf8.decode(respBytes, allowMalformed: true).trim();

      if (responseBody.isEmpty) {
        throw Exception('Empty response body from verification service');
      }

      dynamic decoded;
      try {
        decoded = jsonDecode(responseBody);
      } catch (e) {
        throw Exception('Failed to decode JSON response: $e — body: $responseBody');
      }

      // Support either List or Map response shapes
      Map<String, dynamic>? output;
      if (decoded is List && decoded.isNotEmpty) {
        final first = decoded[0];
        if (first is Map && first.containsKey('output')) {
          output = Map<String, dynamic>.from(first['output'] as Map);
        }
      } else if (decoded is Map && decoded.containsKey('output')) {
        output = Map<String, dynamic>.from(decoded['output'] as Map);
      }

      if (output != null) {
        _workoutResult = output;
        notifyListeners();
        return _workoutResult;
      } else {
        throw Exception('Unexpected response shape from verification service: $decoded');
      }
    } else {
      // Read body (if any) to include in the error message
      final respBytes = await response.stream.toBytes();
      final responseBody = utf8.decode(respBytes, allowMalformed: true).trim();
      throw Exception('Failed to verify image: HTTP ${response.statusCode} — body: $responseBody');
    }
  }

  // Clear stored result
  void clearWorkoutResult() {
    _workoutResult = {};
    notifyListeners();
  }
}
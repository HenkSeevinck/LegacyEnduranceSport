import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AiProvider with ChangeNotifier {

  Future<String> getWorkoutDescriptionSuggestion(String message, Map<String, dynamic> workoutData, String workoutType, String block) async {
    // Send message to n8n workflow for chatbot response
    var url = Uri.parse('https://n8n.seevinckserver.com/webhook/4e148ea7-4cc4-445f-a1d2-dec8b1243685');
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        //'AnimalLogger': authorizationHeader ?? '',
      },
      body: jsonEncode({
        'message': message,
        'WorkoutBlock': block,
        'WorkoutType': workoutType,
        'WorkoutDuration': workoutData['duration'] == 'hh:mm:ss' ? '-' : workoutData['duration'],
        'WorkoutDistance': workoutData['distance'] == '00.00' ? '-' : workoutData['distance'],
      }),
    );

    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      String botReply = 'Sorry, I did not understand that.';

      // Handle responses that may be either a List or a Map and where
      // the 'output' field can be a String or a List.
      if (responseBody is List) {
        if (responseBody.isNotEmpty) {
          final first = responseBody.first;
          if (first is Map && first.containsKey('output')) {
            final out = first['output'];
            if (out is List && out.isNotEmpty) {
              botReply = out.first.toString();
            } else if (out != null) {
              botReply = out.toString();
            }
          } else if (first is String) {
            botReply = first;
          }
        }
      } else if (responseBody is Map) {
        final out = responseBody['output'];
        if (out is List && out.isNotEmpty) {
          botReply = out.first.toString();
        } else if (out != null) {
          botReply = out.toString();
        }
      }

      botReply = botReply.trim();

      notifyListeners();
      return botReply;
    } else {
      throw Exception('Failed to communicate with chatbot: HTTP ${response.statusCode}');
    }
  }


}
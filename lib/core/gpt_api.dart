import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GptApi {
  String imageDataUri(Uint8List imageBytes, {String mimeType = 'image/jpeg'}) {
    final base64String = base64Encode(imageBytes);
    return 'data:$mimeType;base64,$base64String';
  }

  Future<Map<String, dynamic>> getImageResponse(Uint8List imageBytes) async {
    // Load API Key
    final apiKey = dotenv.env['GPT_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return {'error': 'GPT_API_KEY not found in .env'};
    }

    final dataUri = imageDataUri(imageBytes);

    // Manually build messages as raw JSON maps (bypasses package bug)
    final messages = [
      {
        'role': 'system',
        'content': [
          {'type': 'text', 'text': 'You are a calorie estimation assistant. Only reply with calories and food details.'}
        ]
      },
      {
        'role': 'user',
        'content': [
          {'type': 'text', 'text': 'Estimate the calories in this food and give a short description.'},
          {
            'type': 'image_url',
            'image_url': {
              'url': dataUri
            }
          }
        ]
      }
    ];

    final body = jsonEncode({
      'model': 'gpt-4o',
      'messages': messages,
      'max_tokens': 500,
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        print(' GPT Error: ${response.statusCode} - ${errorBody['error']?['message'] ?? response.body}');
        return {'error': 'API Error ${response.statusCode}: ${errorBody['error']?['message'] ?? 'Unknown' }'};
      }

      final data = jsonDecode(response.body);
      final responseText = data['choices']?[0]?['message']?['content'] ?? 'No response';

      final usage = data['usage'] ?? {};
      final promptTokens = usage['prompt_tokens'] ?? 0;
      final completionTokens = usage['completion_tokens'] ?? 0;
      final totalTokens = usage['total_tokens'] ?? 0;

      print('Response: $responseText');
      return {
        'responseText': responseText,
        'promptTokens': promptTokens,
        'completionTokens': completionTokens,
        'totalTokens': totalTokens,
      };
    } catch (e) {
      print('GPT Error: $e');
      return {'error': e.toString()};
    }
  }
}
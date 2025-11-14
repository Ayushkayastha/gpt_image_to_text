import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
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
          {
            'type': 'text',
            'text': '''
            You are a calorie estimation expert. Output only the values in this exact CSV order:
Name, Serving Size, Serving Unit, Calories (kcal), Protein (g), Carbs (g), Fats (g), Fiber (g), Health Score (0-10)

Rules:
- No labels, no extra text.
- If exact data unknown, give best estimate. Only if impossible, use a range.
Output: value1,value2,value3,value4,value5,value6,value7,value8,value9
'''

          }
          ]
      },
      {
        'role': 'user',
        'content': [
          {'type': 'text', 'text': 'Estimate the calories in this food'},
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
      final dio= Dio();
      final response = await dio.post(
        'https://api.openai.com/v1/chat/completions',
        data: body,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        final errorData = response.data is Map ? response.data : {'error': {'message': response.statusMessage}};
        print(' GPT Error: ${response.statusCode} - ${errorData['error']?['message'] ?? response.data}');
        return {'error': 'API Error ${response.statusCode}: ${errorData['error']?['message'] ?? 'Unknown' }'};
      }

      final data = response.data;
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
    } on DioException catch (e) {
      print(' GPT Error (Dio): ${e.response?.statusCode} - ${e.message}');
      final errorMsg = e.response?.data?['error']?['message'] ?? e.message ?? 'Unknown Dio error';
      return {'error': 'Dio Error: $errorMsg'};
    } catch (e) {
      print('GPT Error: $e');
      return {'error': e.toString()};
    }
  }
}
import 'dart:convert';
import 'dart:typed_data';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GptApi{

  String imageUrlParser(Uint8List image){
    String base64Image = base64Encode(image);
    //as the open ai api expects not a plane base64 image but a string or an image url
    String image_url="data:image/jpeg;base64,$base64Image";
    return image_url;
  }

  Future<Map<String, dynamic>> getImageResponse(Uint8List image) async {
    OpenAI.apiKey=dotenv.env['GPT_API_KEY']!;
    String image_url=imageUrlParser(image);
    //this is message to the model on how to behave and thus role is set as system and the content is the promt for the model
    //u can give different kind of promts and roles
    final system_message= OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content:[
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
              'You are a calorie estimation assistant. Only reply with calories and food details'
          ),
        ]
    );

    final user_message = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.user,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(image_url),
      ],
    );

    final request_messages = [system_message, user_message];

    try{
      OpenAIChatCompletionModel chatCompletion =
          await OpenAI.instance.chat.create(
              model: "gpt-4-vision-preview",
              messages: request_messages,
              temperature: 0.15,
              maxTokens: 500,
          );
      if(chatCompletion.choices.isEmpty){
        print('empty answer');
        return {
          'responseText': "No response available",
          'promptTokens': 0,
          'completionTokens': 0,
          'totalTokens': 0,
        };
      }
      else{
        //converts AI response in a single string
        var responseText = chatCompletion.choices
            .map((choice) => choice.message.content
            ?.where((item) => item.type == 'text')
            .map((item) => item.text)
            .join('\n'))
            .where((text) => text != null && text.isNotEmpty)
            .join('\n\n');
        print(responseText);
        int promptTokens = chatCompletion.usage.promptTokens;
        int completionTokens = chatCompletion.usage.completionTokens;
        int totalTokens = promptTokens + completionTokens;
        return {
          'responseText': responseText,
          'promptTokens': promptTokens,
          'completionTokens': completionTokens,
          'totalTokens': totalTokens,
        };
      }
    }
    catch (e){
      if (e is RequestFailedException) {
        return {'error': 'Invalid API key or request failed'};
      } else {
        return {'error': 'An unknown error occurred'};
      }
    }

  }

}
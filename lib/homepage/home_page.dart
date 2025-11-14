import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gpt_image_to_text/homepage/widget/picker_card_widget.dart';
import 'package:gpt_image_to_text/core/my_image_picker.dart';

import '../core/gpt_api.dart';
import '../core/secure_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? _image;
  String? _gptResponse;
  late bool formCamera;
  bool _isLoading = false;


  void _sendImageToGpt(Uint8List image) async {
    setState(() {
      _isLoading = true;
    });

    GptApi api = GptApi();
    Map<String, dynamic> response = await api.getImageResponse(image);
    print('''
        promptTokens: ${response['promptTokens']}
        completionTokens: ${response['completionTokens']}
        totalTokens: ${response['totalTokens']}
        ''');

    setState(() {
      _isLoading = false;
      if (response.containsKey('responseText')) {
        _gptResponse = response['responseText'];
      } else if (response.containsKey('error')) {
        _gptResponse = 'Error: ${response['error']}';
      } else {
        _gptResponse = 'Unknown error occurred';
      }
    });
  }

  void _getImage(bool formCamera) async{
    Uint8List? image;
    MyImagePicker picker=MyImagePicker();
    if(formCamera){
      image= await picker.pickImageFromCamera();
    }
    else{
      image= await picker.pickImageFormGallery();
    }

    if(image!=null){
      setState(() {
        _image=image;
        _gptResponse = null; // clear old response
      });
      _sendImageToGpt(image);
    }
    else{
      print('error fetching image form gallery or camera');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _image==null?
              SizedBox.shrink():
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Image.memory(
                    _image!,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                ),
              ),
          SizedBox(height: 12,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PickerCardWidget(
                  title: 'Choose form camera',
                  onTap: () => _getImage(true),
              ),
              SizedBox(width: 24,),
              PickerCardWidget(
                  title: 'Choose form gallery',
                  onTap: () => _getImage(false),
              ),
            ],

          ),
          SizedBox(height: 12),
          _isLoading
              ? SizedBox.shrink()
              : _gptResponse != null
              ? Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _gptResponse!,
              style: TextStyle(fontSize: 16),
            ),
          )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}

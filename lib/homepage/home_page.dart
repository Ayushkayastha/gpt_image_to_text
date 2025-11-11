import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gpt_image_to_text/homepage/widget/picker_card_widget.dart';
import 'package:gpt_image_to_text/core/my_image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  late bool formCamera;

  void _getImage(bool formCamera) async{
    File? image;
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
      });
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
                child: Image.file(
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

          )
        ],
      ),
    );
  }
}

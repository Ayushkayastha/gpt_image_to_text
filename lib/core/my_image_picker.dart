import 'dart:io';

import 'package:image_picker/image_picker.dart';

class MyImagePicker{

  final ImagePicker _picker=ImagePicker();

  /*
      pickedFile is an XFile object from the image_picker package.
      XFile represents a file (image/video) that may be stored somewhere on the device.
      XFile has a property called path that gives the local file path of the picked file as a string.

      pickedFile.path → "/storage/emulated/0/DCIM/Camera/photo1.jpg"
      File(pickedFile.path) → creates a File object pointing to that path.
      You can now use myFile to read, write, or manipulate the file using dart:io APIs.

      Image.file(_image!)
      Image is a widget which shows image in flutter and Image.file() is a constructor
      that will make image form local file(file path) but File object must be passed
   */
  Future<File?> pickImageFormGallery() async{
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if(pickedFile==null){
      return null;
    }
    return File(pickedFile.path);
  }

  Future<File?> pickImageFromCamera() async{
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if(pickedFile==null){
      return null;
    }
    return File(pickedFile.path);
  }

}
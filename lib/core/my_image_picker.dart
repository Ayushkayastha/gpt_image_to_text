import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
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
  Future<Uint8List?> pickImageFormGallery() async{
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if(pickedFile==null){
      return null;
    }
    return resizeImage(file:  File(pickedFile.path));
  }

  Future<Uint8List?> pickImageFromCamera() async{
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if(pickedFile==null){
      return null;
    }
    return resizeImage(file:  File(pickedFile.path));
  }

  Uint8List? resizeImage({required File file}){
    int maxWidth=1024;
    int maxHeight=1024;
    int imgQuality=85;

    //synchronosly reads the image and returns list of numbers(0-255) image in number
    List<int> imageBytes = file.readAsBytesSync();
    Uint8List uint8Image = Uint8List.fromList(imageBytes);

    //we convert the list into usable image which can be edited
    img.Image? image = img.decodeImage(uint8Image);
    if(image==null){
      return null;
    }
    int width= image.width;
    int height=image.height;

    if(width>height){
      width=maxWidth;
      height=(image.height/image.width * maxHeight).round();
    }
    else{
      height=maxHeight;
      width=(image.width/image.height* maxWidth).round();
    }
    //resizes the image
    img.Image resizedImage= img.copyResize(image,width:width,height:height);
    //changes into JPEG and lowers the quality
    Uint8List compressedBytes = Uint8List.fromList(img.encodeJpg(resizedImage, quality: imgQuality));
    print('image compressed and typecasted');
    return compressedBytes;
  }

}
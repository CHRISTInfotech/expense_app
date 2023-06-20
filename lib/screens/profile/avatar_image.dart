import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../services/database.dart';
import '../../shared/loading.dart';
import '../../shared/theme.dart';
import '../../data/globals.dart' as globals;

class AvatarImage extends StatefulWidget {
  @override
  _AvatarImageState createState() => _AvatarImageState();
}

class _AvatarImageState extends State<AvatarImage> {
  bool loading = false;

  //Track form values
  String _imgUrl = '';
  late File _image;
  final picker = ImagePicker();

  //Retrieve selected image from ImagePicker
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
      return;
    }
  }

  //Upload to Firebase Storage and append to UserData
  Future uploadPic(BuildContext context) async {
    String fileName = basename(_image.path);
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(globals.userData.uid!).child(fileName);
    UploadTask uploadTask = ref.putFile(_image);
    TaskSnapshot taskSnapshot = await uploadTask;
  

    //Retrieve the image link from FirebaseStorage
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    await DatabaseService(uid: globals.userData.uid!).updateUserData(
        globals.userData.fullName!, globals.userData.email!,globals.userData.phoneNumber!,globals.userData.upiId,
        avatar: downloadUrl);

    setState(() {
      print("Avatar uploaded");
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
        content: new Text("Avatar saved!"),
        backgroundColor: kDarkSecondary,
      ));
      loading = false;
      print(downloadUrl);
      _imgUrl = downloadUrl;
    });
  }

  @override
  void initState() {
    super.initState();
    //Load the exisiting user avatar
    if (globals.userData.avatar != '') {
      _imgUrl = globals.userData.avatar!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10.0 * 10,
      width: 10.0 * 10,
      margin: EdgeInsets.only(top: 10.0 * 3),
      child: Stack(
        children: <Widget>[
          //Avatar Image
          CircleAvatar(
            radius: 10.0 * 5,
            child: loading
                ? Loading()
                : _imgUrl == ''
                    ? Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 10.0 * 5,
                      )
                    : ClipOval(
                        child: Image.network(
                          _imgUrl,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        ),
                      ),
            backgroundColor: Colors.black,
          ),

          //Image Edit button placeholder
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 10.0 * 2.5,
              width: 10.0 * 2.5,
              decoration: BoxDecoration(
                  color: Color(0xFFb333fa), shape: BoxShape.circle),
              child: Center(
                  heightFactor: 10.0 * 1.5,
                  widthFactor: 10.0 * 1.5,
                  child: GestureDetector(
                    onTap: () async {
                      print("Pick image clicked");
                      await getImage();
                      if (_image != null) {
                        print("Selected path : $_image");
                        setState(() => loading = true);
                        await uploadPic(context);
                      } else {
                        return;
                      }
                    },
                    child: Icon(
                      Icons.edit,
                      size: 15.0,
                      color: Colors.white,
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

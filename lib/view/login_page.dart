import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'live_video.dart';


class Login extends StatelessWidget {
  var db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double height= MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live video Task'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text('Enter the 4 didgits then go !',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),)),
          SizedBox(height: height*.1,),
          Pinput(
          onCompleted: (pin) async{

            db.collection("users").add({'digits': '$pin'}).then((
                DocumentReference doc) =>
                print('DocumentSnapshot added with ID: ${doc.id}'));

            print(pin);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) =>  LiveVideo(pin: pin,)));
          }
    ),

        ],
      ),
    );
  }
}

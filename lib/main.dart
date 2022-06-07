import 'package:agora_task/view/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

const temp_token= "006281bc967477340bd9bfb7723710db182IADKcsHahjk/WO1/HmyOJ/PTHVLmeMs/3kQmnOJb9Rv7BNJjSIgAAAAAIgA9DfJzymugYgQAAQDRa6BiAgDRa6BiAwDRa6BiBADRa6Bi";
const app_id="281bc967477340bd9bfb7723710db182";

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Login()
    );
  }
}


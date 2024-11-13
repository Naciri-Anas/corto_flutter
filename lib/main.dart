import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mail_logs/firebase_options.dart';
import 'package:mail_logs/home.dart';
import 'login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  // Use FutureBuilder to initialize Firebase asynchronously
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(

      future: Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Gmail Reader',
            home: LoginPage(),
          );
        }
        // Show a loading screen while Firebase initializes
        return CircularProgressIndicator();
      },
    );
  }


}

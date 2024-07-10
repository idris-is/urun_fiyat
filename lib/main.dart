import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:urun_fiyat/MyFile/String.dart';
import 'package:urun_fiyat/Pages/home_page.dart';
import 'package:urun_fiyat/Pages/login.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthController(),
      title: MyTexts().appName,
    );
  }
}

class AuthController extends StatelessWidget {
  const AuthController({super.key});

  @override
  Widget build(BuildContext context) {
    Stream<User?> authStream = FirebaseAuth.instance.authStateChanges();
    return StreamBuilder<User?>(
      stream: authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // veya herhangi bir yükleme animasyonu
        } else {
          if (snapshot.hasData) {
            // Kullanıcı oturum açmışsa HomePage'e yönlendir
            return const HomePage();
          } else {
            // Kullanıcı oturum açmamışsa Login sayfasında kal
            return const Login();
          }
        }
      },
    );
  }
}

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:urun_fiyat/MyFile/String.dart';
import 'package:urun_fiyat/Pages/home_page.dart';
import 'package:urun_fiyat/auth/auth_service.dart';

// ignore: must_be_immutable
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _auth = AuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey formKey = GlobalKey();

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [
            Colors.white,
            Colors.green,
          ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50, left: 15, right: 15),
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 4),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blue),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 100, bottom: 170),
                          child: Column(
                            children: [
                              Text(
                                MyTexts().dukkanAdi,
                                style: myTitleStyle(fontsize: 40),
                              ),
                              Text(
                                MyTexts().uygulamaAdi,
                                style: myTitleStyle(fontsize: 35),
                              )
                            ],
                          ),
                        ),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              _MyTextFormField(
                                textInputAction: TextInputAction.next,
                                controller: emailController,
                                labelText: MyTexts().eMail,
                                obscureText: false,
                                suffix: const Icon(Icons.email),
                                textInputType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 20),
                              _MyTextFormField(
                                textInputAction: TextInputAction.done,
                                controller: passwordController,
                                labelText: MyTexts().password,
                                obscureText: true,
                                suffix: const Icon(Icons.remove_red_eye),
                                textInputType: TextInputType.visiblePassword,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ElevatedButton(
                    onPressed: login,
                    style: ButtonStyle(
                      side: MaterialStateProperty.all(
                          const BorderSide(color: Colors.black, width: 4)),
                      fixedSize: MaterialStateProperty.all<Size>(
                        const Size(
                            double.maxFinite, 48), // Set width to maximum
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.blue, // Background color
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15), // Set radius to 20
                        ),
                      ),
                      overlayColor: MaterialStateProperty.all<Color>(
                        Colors.green, // Overlay color
                      ),
                      shadowColor: MaterialStateProperty.all<Color>(
                        Colors.blue, // Shadow color
                      ),
                    ),
                    child: Text(
                      MyTexts().girisYap,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black, // Text color
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  goToHome(BuildContext context) => Navigator.push(
      context, MaterialPageRoute(builder: (context) => const HomePage()));

  TextStyle myTitleStyle({required double fontsize}) {
    return TextStyle(
        fontStyle: FontStyle.italic, fontSize: fontsize, color: Colors.black);
  }

  login() async {
    final user = await _auth.loginUserWithEmailAndPassword(
        emailController.text, passwordController.text);

    if (user != null) {
      log('User logged in');
      // ignore: use_build_context_synchronously
      goToHome(context);
    }
  }
}

class _MyTextFormField extends StatelessWidget {
  const _MyTextFormField(
      {required this.labelText,
      required this.obscureText,
      required this.suffix,
      required this.textInputType,
      required this.controller,
      required this.textInputAction});

  final String labelText;
  final bool obscureText;
  final Widget suffix;
  final TextInputType textInputType;
  final TextEditingController controller;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: Colors.black),
      textInputAction: textInputAction,
      cursorColor: Colors.black,
      controller: controller,
      keyboardType: textInputType,
      obscureText: obscureText,
      decoration: InputDecoration(
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          suffixIcon: suffix,
          suffixIconColor: Colors.black,
          border: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.black)),
    );
  }
}

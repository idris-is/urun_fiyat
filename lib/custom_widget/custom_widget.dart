import 'package:flutter/material.dart';

import '../MyFile/String.dart';

class CustomWidget {
  TextFormField myTextFormField({
    required String labelText,
    required TextInputAction textInputAction,
    required TextEditingController controller,
    required String? Function(String?)? validator, 
    required TextInputType keyboardType,
    required String hintText
  }) {
    return TextFormField(
      validator: validator,
      controller: controller,
      textInputAction: textInputAction,
      style: const TextStyle(color: Colors.black),
      cursorColor: Colors.black,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyColors().myBlack),
              borderRadius: BorderRadius.circular(4.0)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyColors().myBlack),
              borderRadius: BorderRadius.circular(4.0)),
          labelStyle: TextStyle(color: MyColors().myBlack),
          labelText: labelText,
          border: const OutlineInputBorder()),
    );
  }
}

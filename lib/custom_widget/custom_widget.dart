import 'package:flutter/material.dart';

import '../MyFile/String.dart';

class CustomWidget {
  TextFormField myTextFormField({
    required String labelText,
    required TextInputAction textInputAction,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    required TextInputType keyboardType,
    required String hintText,
  }) {
    return TextFormField(
      validator: validator,
      controller: controller,
      textInputAction: textInputAction,
      style: TextStyle(color: MyColors().myTextColor),
      cursorColor: Colors.black,
      keyboardType: keyboardType,
      decoration: InputDecoration(
          hintText: hintText,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyColors().myBorderColor),
              borderRadius: BorderRadius.circular(4.0)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: MyColors().myBorderColor),
              borderRadius: BorderRadius.circular(4.0)),
          labelStyle: TextStyle(color: MyColors().myBorderColor),
          labelText: labelText,
          border: const OutlineInputBorder()),
    );
  }
}

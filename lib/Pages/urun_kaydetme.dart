import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:loading_overlay/loading_overlay.dart';

import '../MyFile/String.dart';
import '../custom_widget/custom_widget.dart';

class UrunKaydetme extends StatefulWidget {
  final bool isUpdating;
  final Map<String, dynamic> product;
  final String docId;

  const UrunKaydetme({
    Key? key,
    required this.isUpdating,
    required this.product,
    required this.docId,
  }) : super(key: key);

  @override
  State<UrunKaydetme> createState() => _UrunKaydetmeState();
}

class _UrunKaydetmeState extends State<UrunKaydetme> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController uMarkasi = TextEditingController();
  TextEditingController uAdi = TextEditingController();
  TextEditingController uCinsi = TextEditingController();
  TextEditingController uFiyati = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String? imageUrl; // Ürün fotoğrafı URL'si
  File? imageFile; // Seçilen fotoğraf dosyası

  bool _isLoading = false; // State variable to manage loading overlay

  @override
  void initState() {
    super.initState();
    if (widget.isUpdating) {
      uMarkasi.text = widget.product['Urun Markasi'] ?? '';
      uAdi.text = widget.product['Urun Adi'] ?? '';
      uCinsi.text = widget.product['Urun Cinsi'] ?? '';
      uFiyati.text = widget.product['Urun Fiyati']?.toString() ?? '';
      imageUrl = widget.product['imageUrl'];
    } else {
      imageUrl = 'assets/foto.png'; // Varsayılan fotoğraf
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Colors.green,
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 25, right: 15, left: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 4),
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blue,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => _showImageSourceActionSheet(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              backgroundImage: imageFile != null
                                  ? FileImage(imageFile!)
                                  : imageUrl != null
                                      ? (imageUrl!.startsWith('http')
                                          ? NetworkImage(imageUrl!)
                                          : AssetImage(imageUrl!)
                                              as ImageProvider)
                                      : const AssetImage('assets/foto.png'),
                              radius: 50,
                            ),
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: [
                                CustomWidget().myTextFormField(
                                  hintText: MyTexts().umHintText,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return '${MyTexts().uMarkasi} ' '${MyTexts().bosBirakilamaz}';
                                    }
                                    return null;
                                  },
                                  controller: uMarkasi,
                                  textInputAction: TextInputAction.next,
                                  labelText: MyTexts().uMarkasi,
                                  keyboardType: TextInputType.name,
                                ),
                                const SizedBox(height: 20),
                                CustomWidget().myTextFormField(
                                  hintText: MyTexts().uaHintText,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return '${MyTexts().uAdi} ' '${MyTexts().bosBirakilamaz}';
                                    }
                                    return null;
                                  },
                                  controller: uAdi,
                                  textInputAction: TextInputAction.next,
                                  labelText: MyTexts().uAdi,
                                  keyboardType: TextInputType.name,
                                ),
                                const SizedBox(height: 20),
                                CustomWidget().myTextFormField(
                                  hintText: MyTexts().ucHinttext,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return '${MyTexts().uCinsi} ' '${MyTexts().bosBirakilamaz}';
                                    }
                                    return null;
                                  },
                                  controller: uCinsi,
                                  textInputAction: TextInputAction.next,
                                  labelText: MyTexts().uCinsi,
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(height: 20),
                                CustomWidget().myTextFormField(
                                  hintText: MyTexts().ufHintText,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return '${MyTexts().uFiyati} ' '${MyTexts().bosBirakilamaz}';
                                    }
                                    return null;
                                  },
                                  controller: uFiyati,
                                  textInputAction: TextInputAction.done,
                                  labelText: MyTexts().uFiyati,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (widget.isUpdating) {
                          _updateProduct();
                        } else {
                          _saveProduct();
                        }
                      }
                    },
                    style: ButtonStyle(
                      side: MaterialStateProperty.all(
                        const BorderSide(color: Colors.black, width: 4),
                      ),
                      fixedSize: MaterialStateProperty.all<Size>(
                        const Size(double.maxFinite, 48),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      overlayColor:
                          MaterialStateProperty.all<Color>(Colors.green),
                      shadowColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    child: Text(
                      widget.isUpdating ? MyTexts().guncelle : MyTexts().kaydet,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showImageSourceActionSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(MyTexts().kamera),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_album),
                title: Text(MyTexts().galeri),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        imageUrl = pickedFile.path; // Seçilen dosya yolunu sakla
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = _storage.ref().child('urunler/$fileName');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Görsel yüklenirken bir hata oluştu: $e')),
      );
      return null;
    }
  }

  Future<void> _saveProduct() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    String? downloadUrl;
    if (imageFile != null) {
      downloadUrl = await _uploadImage(imageFile!);
    }

    Map<String, dynamic> saveData = {
      'Urun Markasi': uMarkasi.text.toLowerCase(),
      'Urun Adi': uAdi.text.toLowerCase(),
      'Urun Cinsi': uCinsi.text.toLowerCase(),
      'Urun Fiyati': uFiyati.text,
      'imageUrl': downloadUrl ?? 'assets/foto.png',
    };

    // Check if the product with the same brand and name already exists
    QuerySnapshot snapshot = await _firestore
        .collection('Urun')
        .where('Urun Markasi', isEqualTo: uMarkasi.text.toLowerCase())
        .where('Urun Adi', isEqualTo: uAdi.text.toLowerCase())
        .get();

    // Save or update product based on whether it already exists
    if (snapshot.docs.isEmpty) {
      await _firestore.collection('Urun').add(saveData);
    } else {
      await _firestore.collection('Urun').doc(widget.docId).update(saveData);
    }

    setState(() {
      _isLoading = false; // Set loading state to false after saving/updating
    });

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  Future<void> _updateProduct() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    String? downloadUrl;
    if (imageFile != null) {
      downloadUrl = await _uploadImage(imageFile!);
    }

    Map<String, dynamic> updateData = {
      'Urun Markasi': uMarkasi.text.toLowerCase(),
      'Urun Adi': uAdi.text.toLowerCase(),
      'Urun Cinsi': uCinsi.text.toLowerCase(),
      'Urun Fiyati': uFiyati.text,
      'imageUrl': downloadUrl ?? 'assets/foto.png',
    };

    await _firestore.collection('Urun').doc(widget.docId).update(updateData);

    setState(() {
      _isLoading = false; // Set loading state to false after saving/updating
    });

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }
}

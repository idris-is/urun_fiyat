import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import '../MyFile/String.dart';
import '../widgets/custom_widget.dart';

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
  bool _isLoading = false; // Yükleme katmanını yönetmek için durum değişkeni
  @override
  void initState() {
    super.initState();
    if (widget.isUpdating) {
      uMarkasi.text = widget.product['Urun Markasi'] ?? '';
      uAdi.text = widget.product['Urun Adi'] ?? '';
      uCinsi.text = widget.product['Urun Cinsi'] ?? '';
      uFiyati.text = widget.product['Urun Fiyati']?.toString() ?? '';
      imageUrl = widget.product['imageUrl'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFade8f4),
      appBar: AppBar(
        title: Text(widget.isUpdating ? MyTexts().guncelle : MyTexts().kaydet),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height-100,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60, right: 15, left: 15),
                  child: Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: MyColors().myBorderColor, width: 4),
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF48cae4),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => _showImageSourceActionSheet(context),
                          onLongPress: (){
                            showDialog(context: context, builder: (BuildContext context){
                              return Dialog(
                                child: Container(
                                  height: 300,
                                  width: 300,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageFile != null
                                          ? FileImage(imageFile!)
                                          : imageUrl != null
                                          ? (imageUrl!.startsWith('http')
                                          ? NetworkImage(imageUrl!)
                                          : AssetImage(imageUrl!) as ImageProvider)
                                          : const AssetImage('assets/ic_launcher.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Hero(
                              createRectTween: (begin, end) {
                                return RectTween(begin: begin, end: end);
                              },
                              tag: widget.product['id'] ?? 'new_image',
                              child: CircleAvatar(
                                backgroundImage: imageFile != null
                                    ? FileImage(imageFile!)
                                    : imageUrl != null
                                        ? (imageUrl!.startsWith('http')
                                            ? NetworkImage(imageUrl!)
                                            : AssetImage(imageUrl!)
                                                as ImageProvider)
                                        : const AssetImage(
                                            'assets/ic_launcher.png'),
                                radius: 100,
                              ),
                            ),
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              children: [
                                MyTextFormField().myTextFormField(
                                  hintText: MyTexts().umHintText,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return '${MyTexts().uMarkasi} '
                                          '${MyTexts().bosBirakilamaz}';
                                    }
                                    return null;
                                  },
                                  controller: uMarkasi,
                                  textInputAction: TextInputAction.next,
                                  labelText: MyTexts().uMarkasi,
                                  keyboardType: TextInputType.name,
                                ),
                                const SizedBox(height: 20),
                                MyTextFormField().myTextFormField(
                                  hintText: MyTexts().uaHintText,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return '${MyTexts().uAdi} '
                                          '${MyTexts().bosBirakilamaz}';
                                    }
                                    return null;
                                  },
                                  controller: uAdi,
                                  textInputAction: TextInputAction.next,
                                  labelText: MyTexts().uAdi,
                                  keyboardType: TextInputType.name,
                                ),
                                const SizedBox(height: 20),
                                MyTextFormField().myTextFormField(
                                  hintText: MyTexts().ucHinttext,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return '${MyTexts().uCinsi} '
                                          '${MyTexts().bosBirakilamaz}';
                                    }
                                    return null;
                                  },
                                  controller: uCinsi,
                                  textInputAction: TextInputAction.next,
                                  labelText: MyTexts().uCinsi,
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(height: 20),
                                MyTextFormField().myTextFormField(
                                  hintText: MyTexts().ufHintText,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return '${MyTexts().uFiyati} '
                                          '${MyTexts().bosBirakilamaz}';
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
                  padding: const EdgeInsets.only(
                    top: 100,
                    left: 20,
                    right: 20,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (widget.isUpdating) {
                          _updateProduct();
                        } else {
                          if (imageFile != null) {
                            _saveProduct();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(MyTexts().gorselSecin),
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: ButtonStyle(
                      side: WidgetStateProperty.all(
                        const BorderSide(color: Colors.black, width: 4),
                      ),
                      fixedSize: WidgetStateProperty.all<Size>(
                        const Size(double.maxFinite, 48),
                      ),
                      backgroundColor: WidgetStateProperty.all<Color>(
                        const Color(0xFF48cae4),
                      ),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      overlayColor: WidgetStateProperty.all<Color>(
                        const Color(0xFF0096c7),
                      ),
                      shadowColor: WidgetStateProperty.all<Color>(Colors.blue),
                    ),
                    child: Text(
                      widget.isUpdating ? MyTexts().guncelle : MyTexts().kaydet,
                      style: TextStyle(
                        fontSize: 20,
                        color: MyColors().myTextColor,
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

  Future<File> _compressImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) return imageFile;

    // Görüntüyü yeniden boyutlandır ve sıkıştır
    img.Image resizedImage = img.copyResize(image, width: 600);

    final compressedBytes = img.encodeJpg(resizedImage, quality: 70);

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp.jpg');
    await tempFile.writeAsBytes(compressedBytes);

    return tempFile;
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      // Resmi sıkıştır
      File compressedImage = await _compressImage(imageFile);

      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = _storage.ref().child('urunler/$fileName');
      final uploadTask = storageRef.putFile(compressedImage);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${MyTexts().gorselYuklenmeHatasi} $e')),
      );
      return null;
    }
  }

  Future<void> _saveProduct() async {
    setState(() {
      _isLoading = true; // Yükleme durumunu doğru olarak ayarla
    });

    String? downloadUrl = await _uploadImage(imageFile!);

    Map<String, dynamic> saveData = {
      'Urun Markasi': uMarkasi.text.toLowerCase(),
      'Urun Adi': uAdi.text.toLowerCase(),
      'Urun Cinsi': uCinsi.text.toLowerCase(),
      'Urun Fiyati': uFiyati.text,
      'imageUrl': downloadUrl ?? 'assets/ic_launcher.png',
    };

    // Aynı marka ve isimdeki ürünün zaten mevcut olup olmadığını kontrol etmek için
    QuerySnapshot snapshot = await _firestore
        .collection('Urun')
        .where('Urun Markasi', isEqualTo: uMarkasi.text.toLowerCase())
        .where('Urun Adi', isEqualTo: uAdi.text.toLowerCase())
        .where('Urun Cinsi', isEqualTo: uCinsi.text.toLowerCase())
        .get();

    // Aynı marka ve isimde ürün mevcutsa hatayı kaydedin veya gösterin
    if (snapshot.docs.isEmpty) {
      await _firestore.collection('Urun').add(saveData);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(MyTexts().urunMevcut),
        ),
      );
    }

    setState(() {
      _isLoading =
          false; // Kaydettikten/güncelledikten sonra yükleme durumunu false olarak ayarlayın
    });

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  Future<void> _updateProduct() async {
    setState(() {
      _isLoading = true; // Yükleme durumunu true olarak ayarla
    });

    String? downloadUrl =
        imageUrl; // imageFile null ise mevcut imageUrl'yi kullanın

    if (imageFile != null) {
      downloadUrl = await _uploadImage(imageFile!);
    }

    Map<String, dynamic> updateData = {
      'Urun Markasi': uMarkasi.text.toLowerCase(),
      'Urun Adi': uAdi.text.toLowerCase(),
      'Urun Cinsi': uCinsi.text.toLowerCase(),
      'Urun Fiyati': uFiyati.text,
      'imageUrl': downloadUrl ?? 'assets/ic_launcher.png',
    };

    await _firestore.collection('Urun').doc(widget.docId).update(updateData);

    setState(() {
      _isLoading =
          false; // Kaydettikten/güncelledikten sonra yükleme durumunu false olarak ayarlayın
    });

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }
}

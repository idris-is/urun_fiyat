import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:urun_fiyat/MyFile/String.dart';
import 'package:urun_fiyat/Pages/urun_kaydetme.dart';
import 'package:urun_fiyat/widgets/animation.dart';
import 'product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFade8f4),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFade8f4)
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: TextField(
                  cursorColor: Colors.black,
                  controller: searchController,
                  decoration: InputDecoration(
                    // ignore: prefer_const_constructors
                    labelStyle: TextStyle(color: Colors.black),
                    labelText: MyTexts().uAra,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF48cae4),
                    contentPadding: const EdgeInsets.all(20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                        color: MyColors().myBorderColor,
                        width: 3,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide(
                        color: MyColors().myBorderColor,
                        width: 3,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _firestore.collection('Urun').snapshots();
                },
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection('Urun').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                          child:
                              Text('${MyTexts().hataOlustu} ${snapshot.error}'));
                    }
                
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                
                    final products = snapshot.data!.docs.map((doc) {
                      return {
                        'id': doc.id,
                        ...doc.data() as Map<String, dynamic>,
                      };
                    }).where((product) {
                      final productName =
                          product['Urun Adi'].toString().toLowerCase();
                      final productBrand =
                          product['Urun Markasi'].toString().toLowerCase();
                      final searchLower = searchQuery.toLowerCase();
                      return productName.contains(searchLower) ||
                          productBrand.contains(searchLower);
                    }).toList();
                
                    if (products.isEmpty) {
                      return Center(
                        child: Text(
                          MyTexts().uBulunamadi,
                          style: const TextStyle(fontSize: 20),
                        ),
                      );
                    }
                
                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        return SlideAnimationWidget(
                          delay: index * 0.001,
                          child: MyListTile(
                            product: products[index],
                            onUpdate: () => gotoUpdate(context, products[index]),
                            onDelete: () => deleteProduct(context, products[index]),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF48cae4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.black, width: 3),
        ),
        icon: const Icon(Icons.add),
        onPressed: () => gotoAdd(context),
        label: Text(MyTexts().uEkle),
      ),
    );
  }

  void gotoAdd(BuildContext context) {
    goToUrunKaydetme(context, isUpdating: false);
  }

  void gotoUpdate(BuildContext context, Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UrunKaydetme(
          product: product,
          isUpdating: true,
          docId: product['id'],
        ),
      ),
    );
  }

  void goToUrunKaydetme(BuildContext context, {required bool isUpdating}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UrunKaydetme(
          isUpdating: isUpdating,
          product: const {},
          docId: '',
        ),
      ),
    );
  }

  void deleteProduct(BuildContext context, Map<String, dynamic> product) async {
    final docId = product['id'];
    final deletedProduct = {...product};

    await _firestore.collection('Urun').doc(docId).delete();

    // snackbar'ı geciktirmek için Future.microtask kullanın
    Future.microtask(() {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(MyTexts().urunSilindi),
            action: SnackBarAction(
              label: MyTexts().geriAl,
              onPressed: () {
                _firestore.collection('Urun').doc(docId).set(deletedProduct);
              },
            ),
          ),
        );
      }
    });
  }
}

class MyListTile extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const MyListTile({
    Key? key,
    required this.product,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? imageUrl = product['imageUrl'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, top: 10, left: 15, right: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF48cae4),
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(20),
        height: 120, // Sabit yükseklik ayarı
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Fotoğrafı göstermek için CircleAvatar veya Image widget'ını kullanabilirsiniz
            SizedBox(
              width: 70,
              child: GestureDetector(
                onTap: () {
                  // Burada resmin büyütüleceği veya ayrıntılarının gösterileceği bir işlem yapabilirsiniz
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: Image.network(
                          imageUrl!,
                        ), // veya istediğiniz büyütme işlemini yapın
                      );
                    },
                  );
                },
                child: Hero(
                  tag: product['id'], // Hero ile eşleşen tag
                  child: imageUrl != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(imageUrl),
                          radius: 35,
                        )
                      : const CircleAvatar(
                          backgroundImage: AssetImage('assets/ic_launcher.png'),
                          radius: 35,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${MyTexts().adi} ${product['Urun Adi']}',
                    maxLines: 1, // Sadece bir satır göstermek için
                    overflow: TextOverflow
                        .ellipsis, // Taşma durumunda ... göstermek için
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${MyTexts().marka} ${product['Urun Markasi']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${MyTexts().cinsi} ${product['Urun Cinsi']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  MyTexts().fiyat,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: MySize().myFontSize20),
                ),
                Text(
                  '${product['Urun Fiyati']} ${MyTexts().tl}',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: MySize().myFontSize20),
                ),
              ],
            ),
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        onUpdate();
                      },
                      title: Text(
                        MyTexts().guncelle,
                        style: TextStyle(
                            color: MyColors().myTextColor,
                            fontSize: MySize().myFontSize20),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        onDelete();
                      },
                      title: Text(
                        MyTexts().sil,
                        style: TextStyle(
                            color: MyColors().myTextColor,
                            fontSize: MySize().myFontSize20),
                      ),
                    ),
                  ),
                ];
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';

import '../MyFile/String.dart';
class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? imageUrl = product['imageUrl'];

    return Scaffold(
      backgroundColor: const Color(0xFFade8f4),
      appBar: AppBar(
        title: Text(product['Urun Adi']),
        backgroundColor: const Color(0xFF48cae4),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Hero(
                tag: product['id'], // Hero widget ile aynı tag
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      : const Image(
                          image: AssetImage('assets/ic_launcher.png'),
                          width: 200,
                          height: 200,
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${MyTexts().adi} ${product['Urun Adi']}',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                '${MyTexts().marka} ${product['Urun Markasi']}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                '${MyTexts().cinsi} ${product['Urun Cinsi']}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                '${MyTexts().fiyat}: ${product['Urun Fiyati']} ${MyTexts().tl}',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


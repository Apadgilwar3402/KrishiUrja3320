import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String name;
  final String description;
  final String url;
  bool isInCart;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    this.isInCart = false,
  });

  factory Item.fromDocument(DocumentSnapshot doc) {
    return Item(
      id: doc.id,
      name: doc['name'],
      description: doc['description'],
      url: doc['url'],
      isInCart: doc['isInCart'],
    );
  }

  Future<void> toggleCart() async {
    isInCart = !isInCart;
    await FirebaseFirestore.instance.collection('items').doc(id).set({'isInCart': isInCart});
  }
}
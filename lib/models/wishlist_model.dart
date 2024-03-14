import 'package:cloud_firestore/cloud_firestore.dart';

class Wishlist {
  final String id;
  List<String> itemIds;

  Wishlist({required this.id, required this.itemIds});

  factory Wishlist.fromDocument(DocumentSnapshot doc) {
    return Wishlist(
      id: doc.id,
      itemIds: List<String>.from(doc['itemIds']),
    );
  }

  Future<void> addItem(String itemId) async {
    itemIds.add(itemId);
    await FirebaseFirestore.instance.collection('wishlists').doc(id).set({'itemIds': itemIds});
  }

  Future<void> removeItem(String itemId) async {
    itemIds.remove(itemId);
    await FirebaseFirestore.instance.collection('wishlists').doc(id).set({'itemIds': itemIds});
  }
}
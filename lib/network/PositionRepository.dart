import 'package:cloud_firestore/cloud_firestore.dart';

Stream<QuerySnapshot> positionsSnapshot(String currentUserId) {
  return Firestore.instance
      .collection('positions')
      .document(currentUserId)
      .collection(currentUserId)
      .orderBy('createdAt', descending: true)
      .snapshots();
}

import 'package:cloud_firestore/cloud_firestore.dart';

Stream<DocumentSnapshot> userSnapshot(String currentUserId) {
  return Firestore.instance
      .collection('users')
      .document(currentUserId)
      .snapshots();
}

class User {
  final String id;
  final double balance;
  final num pnl;
  final num profit;
  final DocumentReference reference;

  User.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['id'] != null),
        id = map['id'],
        balance = double.parse(map['balance']),
        pnl = map['pnl'],
        profit = map['profit'];

  User.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "User<$id:$balance:$pnl>";
}

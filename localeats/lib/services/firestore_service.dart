import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> ensureUserDocument() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'phone': user.phoneNumber ?? '',
        'photoUrl': user.photoURL ?? '',
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
        'favoriteVendors': [],
        'addresses': [],
        'paymentMethods': [],
        'refundBalance': 0,
        'totalOrders': 0,
      });
    }
  }

  static Future<void> updateUserField(String field, dynamic value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await ensureUserDocument();
    await _db.collection('users').doc(user.uid).update({field: value});
  }

  static Future<void> arrayUnion(String field, dynamic value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await ensureUserDocument();
    await _db.collection('users').doc(user.uid).update({field: FieldValue.arrayUnion([value])});
  }

  static Future<void> arrayRemove(String field, dynamic value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid).update({field: FieldValue.arrayRemove([value])});
  }
}

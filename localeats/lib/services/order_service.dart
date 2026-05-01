import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart_service.dart';

class OrderService {
  static final _db = FirebaseFirestore.instance;

  static Future<String?> placeOrder(CartService cart, String paymentMethod) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || cart.items.isEmpty) return null;
    try {
      final orderId = 'LE-${DateTime.now().millisecondsSinceEpoch}';
      final orderData = {
        'orderId': orderId,
        'userId': user.uid,
        'userName': user.displayName ?? '',
        'userEmail': user.email ?? '',
        'vendorId': cart.vendorId,
        'vendorName': cart.vendorName,
        'items': cart.items.map((i) => {
          'id': i.id,
          'name': i.name,
          'price': i.price,
          'quantity': i.quantity,
          'image': i.image,
        }).toList(),
        'subtotal': cart.subtotal,
        'deliveryFee': cart.deliveryFee,
        'discount': cart.discountAmount,
        'total': cart.total,
        'paymentMethod': paymentMethod,
        'status': 'placed',
        'promoCode': cart.promoCode,
        'createdAt': FieldValue.serverTimestamp(),
        'estimatedDelivery': '15-30 mins',
      };
      await _db.collection('orders').doc(orderId).set(orderData);
      await _db.collection('users').doc(user.uid).update({
        'totalOrders': FieldValue.increment(1),
      });
      return orderId;
    } catch (e) {
      return null;
    }
  }

  static Stream<QuerySnapshot> getUserOrders(String uid) {
    return _db.collection('orders')
      .where('userId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../order/order_tracking_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _promoController = TextEditingController();
  bool _promoApplied = false;
  bool _isPlacingOrder = false;
  String _selectedPayment = 'Cash on Delivery';
  final List<Map<String, String>> _paymentMethods = [
    {'name': 'Cash on Delivery', 'icon': '💵'},
    {'name': 'bKash', 'icon': '💳'},
    {'name': 'Nagad', 'icon': '💰'},
    {'name': 'Rocket', 'icon': '🚀'},
  ];

  Future<void> _placeOrder(CartService cart) async {
    setState(() => _isPlacingOrder = true);
    final orderId = await OrderService.placeOrder(cart, _selectedPayment);
    setState(() => _isPlacingOrder = false);
    if (orderId != null && mounted) {
      cart.clearCart();
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => OrderTrackingScreen(orderId: orderId)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order. Try again.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);

    if (cart.items.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0, automaticallyImplyLeading: false,
          title: const Text('Cart', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('🛒', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          const Text('Your cart is empty', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Add items from a vendor', style: TextStyle(color: Colors.grey[600])),
        ])),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0, automaticallyImplyLeading: false,
        title: Row(children: [
          const Text('Your Cart', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(width: 8),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF2E8B57), borderRadius: BorderRadius.circular(12)),
            child: Text('${cart.itemCount} Items', style: const TextStyle(color: Colors.white, fontSize: 12))),
        ]),
      ),
      body: Column(children: [
        Expanded(child: ListView(padding: const EdgeInsets.all(16), children: [
          // Vendor
          Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.store_outlined, color: Color(0xFF2E8B57), size: 18),
              const SizedBox(width: 8),
              Text(cart.vendorName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E8B57))),
            ])),

          // Items
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            child: Column(children: cart.items.map((item) => Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Container(width: 52, height: 52,
                  decoration: BoxDecoration(color: const Color(0xFFF0F9F4), borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text(item.image, style: const TextStyle(fontSize: 26)))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('৳${item.price.toInt()} each', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ])),
                Row(children: [
                  GestureDetector(onTap: () => cart.removeItem(item.id),
                    child: Container(width: 30, height: 30, decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle), child: const Icon(Icons.remove, size: 16))),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  GestureDetector(onTap: () => cart.addItem(item, '', ''),
                    child: Container(width: 30, height: 30, decoration: const BoxDecoration(color: Color(0xFF2E8B57), shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white, size: 16))),
                ]),
              ]),
            )).toList()),
          ),
          const SizedBox(height: 12),

          // Promo
          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            child: Row(children: [
              const Icon(Icons.local_offer_outlined, color: Color(0xFF2E8B57)),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _promoController,
                decoration: const InputDecoration(hintText: 'Promo code (try LOCALEATS10)', border: InputBorder.none, isDense: true))),
              GestureDetector(
                onTap: () {
                  final applied = cart.applyPromoCode(_promoController.text);
                  setState(() => _promoApplied = applied);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(applied ? '🎉 10% discount applied!' : 'Invalid promo code'),
                    backgroundColor: applied ? const Color(0xFF2E8B57) : Colors.red));
                },
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFF2E8B57), borderRadius: BorderRadius.circular(8)),
                  child: const Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
            ])),
          if (_promoApplied) ...[
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.check_circle, color: Color(0xFF2E8B57), size: 16),
                const SizedBox(width: 8),
                Text('LOCALEATS10 — ${cart.discountPercent.toInt()}% off!', style: const TextStyle(color: Color(0xFF2E8B57), fontWeight: FontWeight.w500, fontSize: 13)),
              ])),
          ],
          const SizedBox(height: 12),

          // Payment
          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              ..._paymentMethods.map((m) => GestureDetector(
                onTap: () => setState(() => _selectedPayment = m['name']!),
                child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _selectedPayment == m['name'] ? const Color(0xFFE8F5E9) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _selectedPayment == m['name'] ? const Color(0xFF2E8B57) : Colors.grey[200]!)),
                  child: Row(children: [
                    Icon(_selectedPayment == m['name'] ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: const Color(0xFF2E8B57), size: 18),
                    const SizedBox(width: 8),
                    Text(m['icon']!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(m['name']!, style: TextStyle(fontWeight: _selectedPayment == m['name'] ? FontWeight.bold : FontWeight.normal)),
                  ])),
              )),
            ])),
          const SizedBox(height: 12),

          // Bill
          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            child: Column(children: [
              _billRow('Subtotal', '৳${cart.subtotal.toInt()}'),
              const SizedBox(height: 8),
              _billRow('Delivery Fee', '৳${cart.deliveryFee.toInt()}'),
              if (_promoApplied) ...[
                const SizedBox(height: 8),
                _billRow('Discount (${cart.discountPercent.toInt()}%)', '-৳${cart.discountAmount.toInt()}', color: const Color(0xFF2E8B57)),
              ],
              const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Text('৳${cart.total.toInt()}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF2E8B57))),
              ]),
            ])),
        ])),

        // Place Order
        Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16)]),
          child: ElevatedButton(
            onPressed: _isPlacingOrder ? null : () => _placeOrder(cart),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: _isPlacingOrder
              ? const CircularProgressIndicator(color: Colors.white)
              : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(_selectedPayment, style: const TextStyle(fontSize: 13)),
                  Text('Place Order ৳${cart.total.toInt()} →', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ]),
          )),
      ]),
    );
  }

  Widget _billRow(String label, String value, {Color? color}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(color: Colors.grey[600])),
      Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: color ?? Colors.black)),
    ]);
}

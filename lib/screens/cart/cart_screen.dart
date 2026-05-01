import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/cart_service.dart';
import '../order/order_tracking_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _promoController = TextEditingController();
  bool _promoApplied = false;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);

    if (cart.items.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🛒', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 16),
              const Text('Your cart is empty',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Add items from a vendor to get started',
                style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text('Your Cart',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2E8B57),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('${cart.itemCount} Items',
                style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Cart items
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    children: cart.items.map((item) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F9F4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(child: Text(item.image,
                              style: const TextStyle(fontSize: 24))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('৳${item.price.toInt()} each',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => cart.removeItem(item.id),
                                child: Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.remove, size: 16),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text('${item.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              GestureDetector(
                                onTap: () => cart.addItem(item, '', ''),
                                child: Container(
                                  width: 28, height: 28,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2E8B57),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // Promo Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_offer_outlined, color: Color(0xFF2E8B57)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _promoController,
                          decoration: const InputDecoration(
                            hintText: 'Enter promo code',
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          final applied = cart.applyPromoCode(_promoController.text);
                          setState(() => _promoApplied = applied);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(applied ? '10% discount applied!' : 'Invalid promo code'),
                            backgroundColor: applied ? const Color(0xFF2E8B57) : Colors.red,
                          ));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E8B57),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Apply',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_promoApplied) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF2E8B57), size: 18),
                        const SizedBox(width: 8),
                        Text('LOCALEATS10 — ${cart.discountPercent.toInt()}% discount applied!',
                          style: const TextStyle(color: Color(0xFF2E8B57), fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Bill Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      _BillRow(label: 'Subtotal', value: '৳${cart.subtotal.toInt()}'),
                      const SizedBox(height: 8),
                      _BillRow(label: 'Delivery Fee', value: '৳${cart.deliveryFee.toInt()}'),
                      if (_promoApplied) ...[
                        const SizedBox(height: 8),
                        _BillRow(
                          label: 'Discount (${cart.discountPercent.toInt()}%)',
                          value: '-৳${cart.discountAmount.toInt()}',
                          valueColor: const Color(0xFF2E8B57),
                        ),
                      ],
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('৳${cart.total.toInt()}',
                            style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold,
                              color: Color(0xFF2E8B57))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Place Order Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16)],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const OrderTrackingScreen()));
                cart.clearCart();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E8B57),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Place Order ৳${cart.total.toInt()} →',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _BillRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(value, style: TextStyle(
          fontWeight: FontWeight.w500,
          color: valueColor ?? Colors.black)),
      ],
    );
  }
}

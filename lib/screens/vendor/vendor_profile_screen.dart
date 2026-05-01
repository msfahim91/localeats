import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/cart_service.dart';
import '../cart/cart_screen.dart';

class VendorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> vendor;
  const VendorProfileScreen({super.key, required this.vendor});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  final List<Map<String, dynamic>> _menuItems = [
    {'id': 'm1', 'name': 'Chicken Biryani', 'desc': 'Fragrant rice with tender chicken', 'price': 220.0, 'emoji': '🍛', 'category': 'Main'},
    {'id': 'm2', 'name': 'Dal Makhani', 'desc': 'Slow-cooked lentils, butter', 'price': 150.0, 'emoji': '🫘', 'category': 'Main'},
    {'id': 'm3', 'name': 'Paratha Set', 'desc': '3 parathas with curry', 'price': 120.0, 'emoji': '🫓', 'category': 'Bread'},
    {'id': 'm4', 'name': 'Beef Kala Bhuna', 'desc': 'Slow cooked spicy beef', 'price': 280.0, 'emoji': '🥩', 'category': 'Main'},
    {'id': 'm5', 'name': 'Vegetable Khichuri', 'desc': 'Comfort food with veggies', 'price': 100.0, 'emoji': '🍲', 'category': 'Main'},
    {'id': 'm6', 'name': 'Lassi', 'desc': 'Sweet or salted yogurt drink', 'price': 60.0, 'emoji': '🥛', 'category': 'Drinks'},
    {'id': 'm7', 'name': 'Mishti Doi', 'desc': 'Sweet yogurt dessert', 'price': 80.0, 'emoji': '🍮', 'category': 'Dessert'},
    {'id': 'm8', 'name': 'Fish Curry', 'desc': 'Fresh fish in spicy gravy', 'price': 200.0, 'emoji': '🐟', 'category': 'Main'},
  ];

  @override
  Widget build(BuildContext context) {
    final vendor = widget.vendor;
    final cart = Provider.of<CartService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF2E8B57),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2E8B57),
                      Color(vendor['color'] as int).withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(vendor['emoji'], style: const TextStyle(fontSize: 64)),
                    Text(vendor['name'],
                      style: const TextStyle(color: Colors.white,
                        fontSize: 22, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        Text(' ${vendor['rating']} • 127 reviews • ${vendor['type']}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoChip(icon: Icons.timer_outlined, label: '${vendor['deliveryTime']} min', sublabel: 'delivery'),
                  _InfoChip(icon: Icons.percent, label: '10%', sublabel: 'commission'),
                  _InfoChip(icon: Icons.delivery_dining_outlined, label: '৳40', sublabel: 'delivery fee'),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('${_menuItems.length} Items',
                    style: const TextStyle(color: Color(0xFF2E8B57), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _menuItems[index];
                final cartItem = cart.items.firstWhere(
                  (i) => i.id == item['id'],
                  orElse: () => CartItem(id: '', name: '', price: 0, image: ''),
                );
                final qty = cartItem.id.isNotEmpty ? cartItem.quantity : 0;

                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: Text(item['emoji'],
                          style: const TextStyle(fontSize: 28))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(item['desc'],
                              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('৳${item['price'].toInt()}',
                              style: const TextStyle(
                                color: Color(0xFF2E8B57),
                                fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                      ),
                      qty == 0
                        ? GestureDetector(
                            onTap: () {
                              cart.addItem(
                                CartItem(
                                  id: item['id'],
                                  name: item['name'],
                                  price: item['price'],
                                  image: item['emoji'],
                                ),
                                vendor['id'],
                                vendor['name'],
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item['name']} added to cart'),
                                  backgroundColor: const Color(0xFF2E8B57),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              width: 32, height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2E8B57),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 20),
                            ),
                          )
                        : Row(
                            children: [
                              GestureDetector(
                                onTap: () => cart.removeItem(item['id']),
                                child: Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.remove, size: 16),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text('$qty',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              GestureDetector(
                                onTap: () => cart.addItem(
                                  CartItem(
                                    id: item['id'],
                                    name: item['name'],
                                    price: item['price'],
                                    image: item['emoji'],
                                  ),
                                  vendor['id'],
                                  vendor['name'],
                                ),
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
                );
              },
              childCount: _menuItems.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: cart.itemCount > 0
        ? Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 16)],
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => CartScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7F50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${cart.itemCount} items',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const Text('View Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('৳${cart.total.toInt()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          )
        : null,
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  const _InfoChip({required this.icon, required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2E8B57), size: 22),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(sublabel, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
      ],
    );
  }
}

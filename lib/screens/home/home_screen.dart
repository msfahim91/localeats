import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/cart_service.dart';
import '../auth/login_screen.dart';
import '../vendor/vendor_profile_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = ['All', 'Pizza', 'Asian', 'Burger', 'Bengali', 'Dessert'];

  final List<Map<String, dynamic>> _demoVendors = [
    {
      'id': 'v1',
      'name': "Mama's Kitchen",
      'type': 'Home Chef',
      'distance': '0.8 km',
      'rating': 4.8,
      'minPrice': 180,
      'maxPrice': 350,
      'deliveryTime': '15-25',
      'category': 'Bengali',
      'emoji': '🏠',
      'color': 0xFFE8F5E9,
    },
    {
      'id': 'v2',
      'name': 'Dhaka Deli',
      'type': 'Bengali Cuisine',
      'distance': '1.2 km',
      'rating': 4.6,
      'minPrice': 120,
      'maxPrice': 280,
      'deliveryTime': '20-30',
      'category': 'Bengali',
      'emoji': '🍛',
      'color': 0xFFFFF3E0,
    },
    {
      'id': 'v3',
      'name': 'Pizza Palace',
      'type': 'Pizza & Fast Food',
      'distance': '0.5 km',
      'rating': 4.5,
      'minPrice': 200,
      'maxPrice': 500,
      'deliveryTime': '15-20',
      'category': 'Pizza',
      'emoji': '🍕',
      'color': 0xFFFFEBEE,
    },
    {
      'id': 'v4',
      'name': 'Asian Garden',
      'type': 'Asian Cuisine',
      'distance': '2.0 km',
      'rating': 4.7,
      'minPrice': 150,
      'maxPrice': 400,
      'deliveryTime': '25-35',
      'category': 'Asian',
      'emoji': '🍜',
      'color': 0xFFE3F2FD,
    },
    {
      'id': 'v5',
      'name': 'Burger Barn',
      'type': 'Burgers & Snacks',
      'distance': '1.5 km',
      'rating': 4.4,
      'minPrice': 100,
      'maxPrice': 250,
      'deliveryTime': '15-25',
      'category': 'Burger',
      'emoji': '🍔',
      'color': 0xFFF3E5F5,
    },
    {
      'id': 'v6',
      'name': 'Sweet Dreams',
      'type': 'Desserts & Sweets',
      'distance': '0.9 km',
      'rating': 4.9,
      'minPrice': 80,
      'maxPrice': 200,
      'deliveryTime': '10-20',
      'category': 'Dessert',
      'emoji': '🍰',
      'color': 0xFFFCE4EC,
    },
  ];

  List<Map<String, dynamic>> get _filteredVendors {
    return _demoVendors.where((v) {
      final matchCategory = _selectedCategory == 'All' || v['category'] == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          v['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final cart = Provider.of<CartService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(user, cart),
          _buildSearchTab(),
          CartScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2E8B57),
          unselectedItemColor: Colors.grey[400],
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Search'),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.shopping_cart_rounded),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 0, top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Color(0xFFFF7F50), shape: BoxShape.circle),
                        child: Text('${cart.itemCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                ],
              ),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab(User? user, CartService cart) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E8B57),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.white70, size: 16),
                                  const SizedBox(width: 4),
                                  const Text('Delivering to',
                                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                                ],
                              ),
                              const Text('Bogura, BD',
                                style: TextStyle(color: Colors.white,
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white24,
                            backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!) : null,
                            child: user?.photoURL == null
                              ? Text(
                                  (user?.displayName?.isNotEmpty == true)
                                    ? user!.displayName![0].toUpperCase() : 'U',
                                  style: const TextStyle(color: Colors.white,
                                    fontWeight: FontWeight.bold))
                              : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('What would you like to eat\ntoday? 🍽️',
                        style: const TextStyle(color: Colors.white,
                          fontSize: 20, fontWeight: FontWeight.bold, height: 1.3)),
                      const SizedBox(height: 16),
                      // Search bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: const InputDecoration(
                            hintText: 'Search restaurants, food...',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            icon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Categories
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Categories',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('See All →',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      final selected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFF2E8B57) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? const Color(0xFF2E8B57) : Colors.grey[200]!),
                          ),
                          child: Text(cat,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.grey[700],
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            )),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Nearby Vendors
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Nearby Vendors',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('See All →',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final vendor = _filteredVendors[index];
                return _VendorCard(vendor: vendor);
              },
              childCount: _filteredVendors.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Search', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  hintText: 'Search restaurants, food...',
                  icon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredVendors.length,
                itemBuilder: (_, i) => _VendorCard(vendor: _filteredVendors[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final Map<String, dynamic> vendor;
  const _VendorCard({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => VendorProfileScreen(vendor: vendor))),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: Color(vendor['color']),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(vendor['emoji'],
                  style: const TextStyle(fontSize: 32))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vendor['name'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.store_outlined, size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(vendor['type'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(width: 8),
                      const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                      Text(vendor['distance'],
                        style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('৳${vendor['minPrice']}-৳${vendor['maxPrice']}',
                        style: const TextStyle(
                          color: Color(0xFF2E8B57),
                          fontWeight: FontWeight.bold, fontSize: 13)),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text('${vendor['rating']}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

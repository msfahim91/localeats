import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../vendor/vendor_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _selectedCategory = 'All';
  RangeValues _priceRange = const RangeValues(0, 1000);
  String _sortBy = 'rating';

  final List<String> _categories = ['All', 'Bengali', 'Pizza', 'Asian', 'Burger', 'Dessert', 'Fast Food'];
  final List<Map<String, dynamic>> _demoVendors = [
    {'id': 'v1', 'name': "Mama's Kitchen", 'type': 'Home Chef', 'distance': '0.8 km', 'rating': 4.8, 'minPrice': 180, 'maxPrice': 350, 'deliveryTime': '15-25', 'category': 'Bengali', 'emoji': '🏠', 'color': 0xFFE8F5E9, 'isDemo': true},
    {'id': 'v2', 'name': 'Dhaka Deli', 'type': 'Bengali Cuisine', 'distance': '1.2 km', 'rating': 4.6, 'minPrice': 120, 'maxPrice': 280, 'deliveryTime': '20-30', 'category': 'Bengali', 'emoji': '🍛', 'color': 0xFFFFF3E0, 'isDemo': true},
    {'id': 'v3', 'name': 'Pizza Palace', 'type': 'Pizza & Fast Food', 'distance': '0.5 km', 'rating': 4.5, 'minPrice': 200, 'maxPrice': 500, 'deliveryTime': '15-20', 'category': 'Pizza', 'emoji': '🍕', 'color': 0xFFFFEBEE, 'isDemo': true},
    {'id': 'v4', 'name': 'Asian Garden', 'type': 'Asian Cuisine', 'distance': '2.0 km', 'rating': 4.7, 'minPrice': 150, 'maxPrice': 400, 'deliveryTime': '25-35', 'category': 'Asian', 'emoji': '🍜', 'color': 0xFFE3F2FD, 'isDemo': true},
    {'id': 'v5', 'name': 'Burger Barn', 'type': 'Burgers & Snacks', 'distance': '1.5 km', 'rating': 4.4, 'minPrice': 100, 'maxPrice': 250, 'deliveryTime': '15-25', 'category': 'Burger', 'emoji': '🍔', 'color': 0xFFF3E5F5, 'isDemo': true},
    {'id': 'v6', 'name': 'Sweet Dreams', 'type': 'Desserts', 'distance': '0.9 km', 'rating': 4.9, 'minPrice': 80, 'maxPrice': 200, 'deliveryTime': '10-20', 'category': 'Dessert', 'emoji': '🍰', 'color': 0xFFFCE4EC, 'isDemo': true},
  ];

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> vendors) {
    var filtered = vendors.where((v) {
      final matchQuery = _query.isEmpty || v['name'].toString().toLowerCase().contains(_query.toLowerCase());
      final matchCat = _selectedCategory == 'All' || v['category'] == _selectedCategory;
      final matchPrice = (v['minPrice'] as int) >= _priceRange.start && (v['maxPrice'] as int) <= _priceRange.end;
      return matchQuery && matchCat && matchPrice;
    }).toList();

    filtered.sort((a, b) {
      if (_sortBy == 'rating') return (b['rating'] as double).compareTo(a['rating'] as double);
      if (_sortBy == 'price') return (a['minPrice'] as int).compareTo(b['minPrice'] as int);
      return 0;
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(hintText: 'Search restaurants, food...', border: InputBorder.none, icon: Icon(Icons.search, color: Colors.grey), isDense: true),
          )),
        elevation: 0,
      ),
      body: Column(children: [
        // Filters
        Container(color: Colors.white, padding: const EdgeInsets.all(12), child: Column(children: [
          // Categories
          SizedBox(height: 36, child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final selected = cat == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: selected ? const Color(0xFF2E8B57) : Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                  child: Text(cat, style: TextStyle(color: selected ? Colors.white : Colors.grey[700], fontSize: 12, fontWeight: selected ? FontWeight.bold : FontWeight.normal))),
              );
            },
          )),
          const SizedBox(height: 10),
          // Price range
          Row(children: [
            const Text('Price: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text('৳${_priceRange.start.toInt()} - ৳${_priceRange.end.toInt()}', style: const TextStyle(fontSize: 12, color: Color(0xFF2E8B57), fontWeight: FontWeight.bold)),
            Expanded(child: RangeSlider(
              values: _priceRange,
              min: 0, max: 1000,
              activeColor: const Color(0xFF2E8B57),
              onChanged: (v) => setState(() => _priceRange = v),
            )),
          ]),
          // Sort
          Row(children: [
            const Text('Sort: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            GestureDetector(onTap: () => setState(() => _sortBy = 'rating'),
              child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: _sortBy == 'rating' ? const Color(0xFF2E8B57) : Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                child: Text('Top Rated', style: TextStyle(color: _sortBy == 'rating' ? Colors.white : Colors.grey[700], fontSize: 12)))),
            GestureDetector(onTap: () => setState(() => _sortBy = 'price'),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: _sortBy == 'price' ? const Color(0xFF2E8B57) : Colors.grey[100], borderRadius: BorderRadius.circular(20)),
                child: Text('Low Price', style: TextStyle(color: _sortBy == 'price' ? Colors.white : Colors.grey[700], fontSize: 12)))),
          ]),
        ])),

        // Results
        Expanded(child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('vendors').where('isActive', isEqualTo: true).where('status', isEqualTo: 'approved').snapshots(),
          builder: (_, snap) {
            final realVendors = (snap.data?.docs ?? []).map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              return {'id': doc.id, 'name': d['name'] ?? '', 'type': d['category'] ?? '', 'distance': '1.0 km', 'rating': (d['rating'] ?? 0.0).toDouble(), 'minPrice': d['minPrice'] ?? 100, 'maxPrice': d['maxPrice'] ?? 500, 'deliveryTime': d['deliveryTime'] ?? '15-30', 'category': d['category'] ?? 'Bengali', 'emoji': d['emoji'] ?? '🍽️', 'color': d['color'] ?? 0xFFE8F5E9, 'isDemo': false};
            }).toList();

            final all = _filter([...realVendors, ..._demoVendors]);

            if (all.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('🔍', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('No vendors found', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            ]));

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: all.length,
              itemBuilder: (_, i) => _VendorCard(vendor: all[i]),
            );
          },
        )),
      ]),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final Map<String, dynamic> vendor;
  const _VendorCard({required this.vendor});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VendorProfileScreen(vendor: vendor))),
    child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Row(children: [
        Container(width: 56, height: 56, decoration: BoxDecoration(color: Color(vendor['color'] as int), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(vendor['emoji'], style: const TextStyle(fontSize: 28)))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(vendor['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text('${vendor['type']} • ${vendor['distance']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('৳${vendor['minPrice']}-৳${vendor['maxPrice']}', style: const TextStyle(color: Color(0xFF2E8B57), fontWeight: FontWeight.bold, fontSize: 13)),
            Row(children: [const Icon(Icons.star_rounded, size: 14, color: Colors.amber), Text(' ${vendor['rating']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]),
          ]),
        ])),
      ]),
    ),
  );
}

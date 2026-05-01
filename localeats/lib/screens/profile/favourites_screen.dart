import 'package:flutter/material.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});
  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final List<Map<String, dynamic>> _favourites = [
    {'name': "Mama's Kitchen", 'type': 'Home Chef', 'rating': 4.8, 'emoji': '🏠', 'color': 0xFFE8F5E9},
    {'name': 'Pizza Palace', 'type': 'Pizza & Fast Food', 'rating': 4.5, 'emoji': '🍕', 'color': 0xFFFFEBEE},
    {'name': 'Sweet Dreams', 'type': 'Desserts', 'rating': 4.9, 'emoji': '🍰', 'color': 0xFFFCE4EC},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, title: const Text('Favourites'), elevation: 0),
      body: _favourites.isEmpty
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('❤️', style: TextStyle(fontSize: 64)), SizedBox(height: 16), Text('No favourites yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _favourites.length,
            itemBuilder: (_, i) {
              final v = _favourites[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                child: Row(children: [
                  Container(width: 56, height: 56, decoration: BoxDecoration(color: Color(v['color']), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(v['emoji'], style: const TextStyle(fontSize: 28)))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(v['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(v['type'], style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    Row(children: [const Icon(Icons.star_rounded, color: Colors.amber, size: 14), Text(' ${v['rating']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]),
                  ])),
                  IconButton(icon: const Icon(Icons.favorite, color: Colors.red), onPressed: () => setState(() => _favourites.removeAt(i))),
                ]),
              );
            }),
    );
  }
}

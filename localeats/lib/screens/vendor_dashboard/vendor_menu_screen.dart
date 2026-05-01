import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VendorMenuScreen extends StatelessWidget {
  final String vendorId;
  const VendorMenuScreen({super.key, required this.vendorId});

  void _showAddEditDialog(BuildContext context, {Map<String, dynamic>? item, String? itemId}) {
    final nameCtrl = TextEditingController(text: item?['name'] ?? '');
    final priceCtrl = TextEditingController(text: item?['price']?.toString() ?? '');
    final descCtrl = TextEditingController(text: item?['desc'] ?? '');
    String selectedEmoji = item?['emoji'] ?? '🍛';
    String selectedCategory = item?['category'] ?? 'Main';
    bool isAvailable = item?['isAvailable'] ?? true;

    final emojis = ['🍛', '🍜', '🍕', '🍔', '🥩', '🍲', '🐟', '🥗', '🫓', '🥛', '🍮', '🍰', '☕'];
    final categories = ['Main', 'Bread', 'Drinks', 'Dessert', 'Snacks', 'Special'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(item == null ? 'Add Menu Item' : 'Edit Item',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ]),
              const SizedBox(height: 12),

              // Emoji picker — Wrap instead of ListView
              const Text('Icon', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: emojis.map((emoji) => GestureDetector(
                  onTap: () => setModalState(() => selectedEmoji = emoji),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: selectedEmoji == emoji ? const Color(0xFFE8F5E9) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: selectedEmoji == emoji ? const Color(0xFF2E8B57) : Colors.transparent)),
                    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22)))),
                )).toList(),
              ),
              const SizedBox(height: 14),

              const Text('Item Name *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(controller: nameCtrl,
                decoration: InputDecoration(
                  hintText: 'e.g. Chicken Biryani',
                  filled: true, fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
              const SizedBox(height: 12),

              const Text('Price (৳) *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g. 220', prefixText: '৳ ',
                  filled: true, fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
              const SizedBox(height: 12),

              const Text('Description', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(controller: descCtrl, maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Brief description',
                  filled: true, fillColor: Colors.grey[100],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
              const SizedBox(height: 12),

              const Text('Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                  value: selectedCategory, isExpanded: true,
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setModalState(() => selectedCategory = v!),
                ))),
              const SizedBox(height: 12),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Available', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Switch(
                  value: isAvailable,
                  onChanged: (v) => setModalState(() => isAvailable = v),
                  activeColor: const Color(0xFF2E8B57)),
              ]),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name and price required'), backgroundColor: Colors.red));
                    return;
                  }
                  final menuData = {
                    'name': nameCtrl.text.trim(),
                    'price': double.tryParse(priceCtrl.text.trim()) ?? 0,
                    'desc': descCtrl.text.trim(),
                    'emoji': selectedEmoji,
                    'category': selectedCategory,
                    'isAvailable': isAvailable,
                    'vendorId': vendorId,
                    'updatedAt': FieldValue.serverTimestamp(),
                  };
                  if (item == null) {
                    menuData['createdAt'] = FieldValue.serverTimestamp();
                    await FirebaseFirestore.instance
                      .collection('vendors').doc(vendorId)
                      .collection('menu').add(menuData);
                  } else {
                    await FirebaseFirestore.instance
                      .collection('vendors').doc(vendorId)
                      .collection('menu').doc(itemId).update(menuData);
                  }
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(item == null ? 'Item added!' : 'Item updated!'),
                      backgroundColor: const Color(0xFF2E8B57)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E8B57),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(item == null ? 'Add Item' : 'Update Item',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
        title: const Text('My Menu'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddEditDialog(context))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('vendors').doc(vendorId)
          .collection('menu').snapshots(),
        builder: (_, snap) {
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('🍽️', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('No menu items yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Tap + to add your first item', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddEditDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add First Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E8B57),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
          ]));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final isAvail = data['isAvailable'] ?? true;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isAvail ? Colors.white : Colors.grey[50],
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
                child: Row(children: [
                  Container(width: 54, height: 54,
                    decoration: BoxDecoration(color: const Color(0xFFF0F9F4), borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(data['emoji'] ?? '🍛', style: const TextStyle(fontSize: 28)))),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(data['name'] ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isAvail ? Colors.black : Colors.grey)),
                    if ((data['desc'] ?? '').isNotEmpty)
                      Text(data['desc'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    Row(children: [
                      Text('৳${(data['price'] ?? 0).toInt()}',
                        style: const TextStyle(color: Color(0xFF2E8B57), fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
                        child: Text(data['category'] ?? '', style: const TextStyle(color: Color(0xFF2E8B57), fontSize: 10))),
                    ]),
                  ])),
                  Column(children: [
                    Switch(
                      value: isAvail,
                      onChanged: (v) => FirebaseFirestore.instance
                        .collection('vendors').doc(vendorId)
                        .collection('menu').doc(docs[i].id).update({'isAvailable': v}),
                      activeColor: const Color(0xFF2E8B57)),
                    Row(children: [
                      GestureDetector(
                        onTap: () => _showAddEditDialog(context, item: data, itemId: docs[i].id),
                        child: const Icon(Icons.edit_outlined, color: Color(0xFF2E8B57), size: 20)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => showDialog(context: context, builder: (ctx) => AlertDialog(
                          title: const Text('Delete Item?'),
                          content: Text('Delete "${data['name']}"?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                  .collection('vendors').doc(vendorId)
                                  .collection('menu').doc(docs[i].id).delete();
                                if (ctx.mounted) Navigator.pop(ctx);
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red))),
                          ],
                        )),
                        child: const Icon(Icons.delete_outline, color: Colors.red, size: 20)),
                    ]),
                  ]),
                ]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        backgroundColor: const Color(0xFF2E8B57),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

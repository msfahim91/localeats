import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});
  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _uid = FirebaseAuth.instance.currentUser?.uid;
  final _labelController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedIcon = 'home';
  bool _isLoading = false;

  final Map<String, IconData> _icons = {
    'home': Icons.home_outlined,
    'work': Icons.work_outlined,
    'school': Icons.school_outlined,
    'other': Icons.location_on_outlined,
  };

  Future<void> _addAddress() async {
    if (_labelController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final newAddress = {
        'label': _labelController.text.trim(),
        'address': _addressController.text.trim(),
        'icon': _selectedIcon,
        'createdAt': DateTime.now().toIso8601String(),
      };
      await FirestoreService.arrayUnion('addresses', newAddress);
      _labelController.clear();
      _addressController.clear();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Address saved!'), backgroundColor: Color(0xFF2E8B57)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
    setState(() => _isLoading = false);
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModalState) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Add New Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Type', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: _icons.entries.map((e) => GestureDetector(
            onTap: () => setModalState(() => _selectedIcon = e.key),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedIcon == e.key ? const Color(0xFFE8F5E9) : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _selectedIcon == e.key ? const Color(0xFF2E8B57) : Colors.transparent)),
              child: Column(children: [
                Icon(e.value, color: _selectedIcon == e.key ? const Color(0xFF2E8B57) : Colors.grey, size: 20),
                const SizedBox(height: 4),
                Text(e.key.toUpperCase(), style: TextStyle(fontSize: 9, color: _selectedIcon == e.key ? const Color(0xFF2E8B57) : Colors.grey)),
              ])),
          )).toList()),
          const SizedBox(height: 12),
          TextField(
            controller: _labelController,
            decoration: InputDecoration(hintText: 'Label (e.g. Home, Office)', prefixIcon: const Icon(Icons.label_outline), filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _addressController, maxLines: 2,
            decoration: InputDecoration(hintText: 'Full address (Area, City)', prefixIcon: const Icon(Icons.location_on_outlined), filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _addAddress,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Address', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 20),
        ]),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, title: const Text('Saved Addresses'), elevation: 0),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(_uid).snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final addresses = data?['addresses'] as List? ?? [];
          return Column(children: [
            Expanded(child: addresses.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('📍', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text('No addresses saved', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Add your home, work or other addresses', style: TextStyle(color: Colors.grey[600])),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: addresses.length,
                  itemBuilder: (_, i) {
                    final addr = addresses[i] as Map<String, dynamic>;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                      child: Row(children: [
                        Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
                          child: Icon(_icons[addr['icon']] ?? Icons.location_on_outlined, color: const Color(0xFF2E8B57))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(addr['label'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(addr['address'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ])),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            await FirestoreService.arrayRemove('addresses', addr);
                            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Address removed'), backgroundColor: Colors.red));
                          }),
                      ]),
                    );
                  })),
            Padding(padding: const EdgeInsets.all(16), child: ElevatedButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add_location_outlined),
              label: const Text('Add New Address'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            )),
          ]);
        },
      ),
    );
  }
}

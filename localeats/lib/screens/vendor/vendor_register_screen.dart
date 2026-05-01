import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class VendorRegisterScreen extends StatefulWidget {
  const VendorRegisterScreen({super.key});
  @override
  State<VendorRegisterScreen> createState() => _VendorRegisterScreenState();
}

class _VendorRegisterScreenState extends State<VendorRegisterScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedCategory = 'Bengali';
  bool _isLoading = false;

  final List<String> _categories = ['Bengali', 'Pizza', 'Asian', 'Burger', 'Dessert', 'Fast Food', 'Healthy', 'Other'];

  Future<void> _registerVendor() async {
    if (_nameController.text.isEmpty || _descController.text.isEmpty ||
        _phoneController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await FirestoreService.ensureUserDocument();

      await FirebaseFirestore.instance.collection('vendors').doc(user.uid).set({
        'id': user.uid,
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'category': _selectedCategory,
        'ownerId': user.uid,
        'ownerName': user.displayName ?? '',
        'ownerEmail': user.email ?? '',
        'rating': 0.0,
        'totalOrders': 0,
        'isVerified': false,
        'isActive': false,
        'commission': 10,
        'deliveryTime': '15-30',
        'deliveryFee': 40,
        'emoji': '🍽️',
        'color': 0xFFE8F5E9,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      await FirestoreService.updateUserField('role', 'vendor_pending');
      await FirestoreService.updateUserField('vendorId', user.uid);

      if (mounted) {
        showDialog(context: context, barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Application Submitted! 🎉'),
            content: const Text('Your vendor application has been submitted!\n\nOur team will review within 24-48 hours. You will be notified once approved.\n\nThank you for joining LocalEats!'),
            actions: [ElevatedButton(
              onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white),
              child: const Text('OK'),
            )],
          ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, title: const Text('Become a Vendor'), elevation: 0),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2E8B57), Color(0xFF4CAF50)]), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Join LocalEats as a Vendor! 🍽️', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _benefit('Only 10% commission (vs 25-30% others)'),
            _benefit('Reach customers within 5km radius'),
            _benefit('Real-time order management'),
            _benefit('Daily payment settlement'),
            _benefit('Free setup & onboarding'),
          ]),
        ),
        const SizedBox(height: 24),
        const Text('Business Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _label('Restaurant/Kitchen Name *'),
        const SizedBox(height: 8),
        _field(_nameController, "e.g. Mama's Kitchen", Icons.restaurant_outlined),
        const SizedBox(height: 16),
        _label('Description *'),
        const SizedBox(height: 8),
        TextField(controller: _descController, maxLines: 3,
          decoration: InputDecoration(hintText: 'Describe your food and specialty...', filled: true, fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E8B57))))),
        const SizedBox(height: 16),
        _label('Food Category *'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value: _selectedCategory, isExpanded: true,
            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _selectedCategory = v!),
          ))),
        const SizedBox(height: 16),
        _label('Contact Phone *'),
        const SizedBox(height: 8),
        _field(_phoneController, '01XXXXXXXXX', Icons.phone_outlined, type: TextInputType.phone),
        const SizedBox(height: 16),
        _label('Business Address *'),
        const SizedBox(height: 8),
        _field(_addressController, 'Full address', Icons.location_on_outlined),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _registerVendor,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Application', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        const Center(child: Text('Applications reviewed within 24-48 hours', style: TextStyle(color: Colors.grey, fontSize: 12))),
      ])),
    );
  }

  Widget _benefit(String text) => Padding(padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [const Icon(Icons.check_circle, color: Colors.white70, size: 16), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)))]));
  Widget _label(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14));
  Widget _field(TextEditingController c, String hint, IconData icon, {TextInputType type = TextInputType.text}) => TextField(
    controller: c, keyboardType: type,
    decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: const Color(0xFF2E8B57)), filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E8B57)))));
}

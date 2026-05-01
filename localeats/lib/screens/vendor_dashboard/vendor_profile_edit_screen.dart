import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class VendorProfileEditScreen extends StatefulWidget {
  final String vendorId;
  const VendorProfileEditScreen({super.key, required this.vendorId});
  @override
  State<VendorProfileEditScreen> createState() => _VendorProfileEditScreenState();
}

class _VendorProfileEditScreenState extends State<VendorProfileEditScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  String _category = 'Bengali';
  String _deliveryTime = '15-30';
  bool _isActive = false;
  bool _isLoading = false;
  String? _currentLogoUrl;
  Uint8List? _newLogoBytes;
  String _selectedEmoji = '🍽️';

  final List<String> _categories = ['Bengali', 'Pizza', 'Asian', 'Burger', 'Dessert', 'Fast Food', 'Healthy'];
  final List<String> _times = ['10-20', '15-30', '20-40', '30-60'];
  final List<String> _emojis = ['🍽️', '🏠', '🍛', '🍕', '🍔', '🍜', '🥗', '🍱', '🧆', '🍰', '☕', '🌮'];

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final doc = await FirebaseFirestore.instance.collection('vendors').doc(widget.vendorId).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _nameCtrl.text = data['name'] ?? '';
        _descCtrl.text = data['description'] ?? '';
        _phoneCtrl.text = data['phone'] ?? '';
        _addressCtrl.text = data['address'] ?? '';
        _category = data['category'] ?? 'Bengali';
        _deliveryTime = data['deliveryTime'] ?? '15-30';
        _isActive = data['isActive'] ?? false;
        _currentLogoUrl = data['logoUrl'];
        _selectedEmoji = data['emoji'] ?? '🍽️';
      });
    }
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, imageQuality: 75);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _newLogoBytes = bytes);
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      String? logoUrl = _currentLogoUrl;
      if (_newLogoBytes != null) {
        final ref = FirebaseStorage.instance.ref().child('vendor_logos/${widget.vendorId}.jpg');
        await ref.putData(_newLogoBytes!, SettableMetadata(contentType: 'image/jpeg'));
        logoUrl = await ref.getDownloadURL();
      }
      await FirebaseFirestore.instance.collection('vendors').doc(widget.vendorId).update({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'category': _category,
        'deliveryTime': _deliveryTime,
        'isActive': _isActive,
        'emoji': _selectedEmoji,
        if (logoUrl != null) 'logoUrl': logoUrl,
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Store updated!'), backgroundColor: Color(0xFF2E8B57)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, title: const Text('My Store'), automaticallyImplyLeading: false,
        actions: [TextButton(onPressed: _isLoading ? null : _save, child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))]),
      body: ListView(padding: const EdgeInsets.all(16), children: [

        // Logo Upload
        Center(child: Stack(children: [
          Container(width: 100, height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9), shape: BoxShape.circle,
              image: _newLogoBytes != null ? DecorationImage(image: MemoryImage(_newLogoBytes!), fit: BoxFit.cover)
                : (_currentLogoUrl != null ? DecorationImage(image: NetworkImage(_currentLogoUrl!), fit: BoxFit.cover) : null)),
            child: (_newLogoBytes == null && _currentLogoUrl == null)
              ? Center(child: Text(_selectedEmoji, style: const TextStyle(fontSize: 48))) : null),
          Positioned(bottom: 0, right: 0,
            child: GestureDetector(onTap: _pickLogo,
              child: Container(width: 30, height: 30, decoration: const BoxDecoration(color: Color(0xFF2E8B57), shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16)))),
        ])),
        const SizedBox(height: 8),
        const Center(child: Text('Tap camera to change logo', style: TextStyle(color: Colors.grey, fontSize: 12))),
        const SizedBox(height: 16),

        // Emoji picker
        const Text('Store Icon', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _emojis.map((e) => GestureDetector(
          onTap: () => setState(() => _selectedEmoji = e),
          child: Container(width: 44, height: 44,
            decoration: BoxDecoration(
              color: _selectedEmoji == e ? const Color(0xFFE8F5E9) : Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _selectedEmoji == e ? const Color(0xFF2E8B57) : Colors.transparent)),
            child: Center(child: Text(e, style: const TextStyle(fontSize: 22)))))).toList()),
        const SizedBox(height: 16),

        // Store Status
        Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Store Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(_isActive ? '🟢 Open' : '🔴 Closed', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ]),
            Switch(value: _isActive, onChanged: (v) => setState(() => _isActive = v), activeColor: const Color(0xFF2E8B57)),
          ])),
        const SizedBox(height: 12),

        // Info
        Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Store Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            _field(_nameCtrl, 'Store Name', Icons.store_outlined),
            const SizedBox(height: 10),
            TextField(controller: _descCtrl, maxLines: 2,
              decoration: InputDecoration(hintText: 'Description', filled: true, fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[200]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2E8B57))))),
            const SizedBox(height: 10),
            _field(_phoneCtrl, 'Phone', Icons.phone_outlined, type: TextInputType.phone),
            const SizedBox(height: 10),
            _field(_addressCtrl, 'Address', Icons.location_on_outlined),
            const SizedBox(height: 10),
            _dropdown(_categories, _category, (v) => setState(() => _category = v!), 'Category'),
            const SizedBox(height: 10),
            _dropdown(_times, _deliveryTime, (v) => setState(() => _deliveryTime = v!), 'Delivery Time'),
          ])),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
      ]),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon, {TextInputType type = TextInputType.text}) => TextField(
    controller: c, keyboardType: type,
    decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: const Color(0xFF2E8B57)),
      filled: true, fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2E8B57)))));

  Widget _dropdown(List<String> items, String value, Function(String?) onChange, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey[200]!)),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(
      value: value, isExpanded: true,
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChange)));
}

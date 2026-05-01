import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? '';
    _phoneController.text = user?.phoneNumber ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, imageQuality: 75);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      String? photoURL;

      if (_imageBytes != null) {
        final ref = FirebaseStorage.instance.ref().child('profile_pics/${user.uid}.jpg');
        await ref.putData(_imageBytes!, SettableMetadata(contentType: 'image/jpeg'));
        photoURL = await ref.getDownloadURL();
        await user.updatePhotoURL(photoURL);
      }

      await user.updateDisplayName(_nameController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!'), backgroundColor: Color(0xFF2E8B57)));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white,
        title: const Text('Edit Profile'), elevation: 0,
        actions: [TextButton(onPressed: _isLoading ? null : _saveProfile, child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))],
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const SizedBox(height: 16),
        Center(child: Stack(children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: const Color(0xFFE8F5E9),
            backgroundImage: _imageBytes != null
              ? MemoryImage(_imageBytes!) as ImageProvider
              : (user?.photoURL != null ? NetworkImage(user!.photoURL!) : null),
            child: (_imageBytes == null && user?.photoURL == null)
              ? Text((user?.displayName?.isNotEmpty == true) ? user!.displayName![0].toUpperCase() : 'U',
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF2E8B57)))
              : null,
          ),
          Positioned(bottom: 0, right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(color: Color(0xFF2E8B57), shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20)),
            )),
        ])),
        const SizedBox(height: 8),
        const Center(child: Text('Tap camera to change photo', style: TextStyle(color: Colors.grey, fontSize: 12))),
        const SizedBox(height: 28),
        const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        _buildField(_nameController, 'Enter your name', Icons.person_outlined),
        const SizedBox(height: 20),
        const Text('Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
          child: Row(children: [Icon(Icons.email_outlined, color: Colors.grey[400]), const SizedBox(width: 12), Text(user?.email ?? 'No email', style: TextStyle(color: Colors.grey[500]))])),
        const SizedBox(height: 20),
        const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        _buildField(_phoneController, 'Enter phone number', Icons.phone_outlined, type: TextInputType.phone),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ]),
    );
  }

  Widget _buildField(TextEditingController c, String hint, IconData icon, {TextInputType type = TextInputType.text}) => TextField(
    controller: c, keyboardType: type,
    decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: const Color(0xFF2E8B57)),
      filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2E8B57)))),
  );
}

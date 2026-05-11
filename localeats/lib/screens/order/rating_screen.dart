import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/home_screen.dart';

class RatingScreen extends StatefulWidget {
  final String orderId;
  final String vendorId;
  final String vendorName;
  const RatingScreen({super.key, required this.orderId, required this.vendorId, required this.vendorName});
  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0;
  final _reviewCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a rating'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance.collection('reviews').add({
        'orderId': widget.orderId,
        'vendorId': widget.vendorId,
        'vendorName': widget.vendorName,
        'userId': user.uid,
        'userName': user.displayName ?? 'User',
        'rating': _rating,
        'review': _reviewCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update vendor rating
      final reviews = await FirebaseFirestore.instance.collection('reviews').where('vendorId', isEqualTo: widget.vendorId).get();
      final avgRating = reviews.docs.fold<double>(0, (sum, doc) => sum + (doc.data()['rating'] ?? 0)) / reviews.docs.length;
      await FirebaseFirestore.instance.collection('vendors').doc(widget.vendorId).update({
        'rating': double.parse(avgRating.toStringAsFixed(1)),
        'totalReviews': reviews.docs.length,
      });

      await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({'rated': true});

      if (mounted) {
        showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
          title: const Text('Thank you! ⭐'),
          content: const Text('Your review has been submitted successfully!'),
          actions: [ElevatedButton(
            onPressed: () { Navigator.pop(ctx); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())); },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white),
            child: const Text('Back to Home'))],
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
      appBar: AppBar(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, title: const Text('Rate Your Order'), elevation: 0),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [
        const SizedBox(height: 20),
        Container(width: 80, height: 80, decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
          child: const Center(child: Text('⭐', style: TextStyle(fontSize: 40)))),
        const SizedBox(height: 16),
        Text('How was your order from', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const SizedBox(height: 4),
        Text(widget.vendorName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),

        // Stars
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => GestureDetector(
          onTap: () => setState(() => _rating = i + 1.0),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
              color: Colors.amber, size: 48)),
        ))),
        const SizedBox(height: 8),
        Text(_getRatingText(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E8B57))),
        const SizedBox(height: 32),

        // Review
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Write a review (optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 10),
            TextField(controller: _reviewCtrl, maxLines: 4, maxLength: 200,
              decoration: InputDecoration(hintText: 'Share your experience...', filled: true, fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[200]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2E8B57))))),
          ])),
        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: _isLoading ? null : _submitReview,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Review', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        const SizedBox(height: 12),
        TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen())), child: const Text('Skip', style: TextStyle(color: Colors.grey))),
      ])),
    );
  }

  String _getRatingText() {
    switch (_rating.toInt()) {
      case 1: return 'Poor 😞';
      case 2: return 'Fair 😐';
      case 3: return 'Good 😊';
      case 4: return 'Very Good 😄';
      case 5: return 'Excellent! 🤩';
      default: return 'Tap to rate';
    }
  }
}

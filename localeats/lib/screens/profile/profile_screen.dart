import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'order_history_screen.dart';
import 'favourites_screen.dart';
import 'addresses_screen.dart';
import 'payment_screen.dart';
import 'notifications_screen.dart';
import 'help_screen.dart';
import 'vouchers_screen.dart';
import '../vendor/vendor_register_screen.dart';
import '../vendor_dashboard/vendor_dashboard_screen.dart';
import '../admin/admin_panel_screen.dart';

const List<String> ADMIN_UIDS = ['07On9nFvRHVtZWs6zBRrfdi4Fqq2', 'tCCYJUveGgeXxN2sNWsbaJSaYQL2'];

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = ADMIN_UIDS.contains(user?.uid);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (_, userSnap) {
          final userData = userSnap.data?.data() as Map<String, dynamic>? ?? {};
          final role = userData['role'] ?? 'customer';
          final isVendor = role == 'vendor';

          return ListView(children: [
            // Header
            Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(20, 16, 20, 20), child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Row(children: [
                  if (isAdmin) IconButton(icon: const Icon(Icons.admin_panel_settings, color: Colors.purple), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPanelScreen()))),
                  IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
                ]),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                Stack(children: [
                  CircleAvatar(radius: 36, backgroundColor: const Color(0xFFE8F5E9),
                    backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: user?.photoURL == null ? Text((user?.displayName?.isNotEmpty == true) ? user!.displayName![0].toUpperCase() : 'U', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2E8B57))) : null),
                  Positioned(bottom: 0, right: 0, child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                    child: Container(width: 24, height: 24, decoration: const BoxDecoration(color: Color(0xFF2E8B57), shape: BoxShape.circle), child: const Icon(Icons.edit, color: Colors.white, size: 14)))),
                ]),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(user?.displayName ?? 'User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    if (isAdmin) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.purple.shade100, borderRadius: BorderRadius.circular(10)), child: const Text('Admin', style: TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.bold))),
                    if (isVendor && !isAdmin) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)), child: const Text('Vendor', style: TextStyle(color: Color(0xFF2E8B57), fontSize: 11, fontWeight: FontWeight.bold))),
                  ]),
                  const SizedBox(height: 4),
                  Text(user?.email ?? user?.phoneNumber ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFF2E8B57)), borderRadius: BorderRadius.circular(20)),
                      child: const Text('Edit Profile', style: TextStyle(color: Color(0xFF2E8B57), fontSize: 12, fontWeight: FontWeight.w500)))),
                ])),
              ]),
            ])),
            const SizedBox(height: 8),

            // Admin Panel Button
            if (isAdmin) Container(color: Colors.white, padding: const EdgeInsets.all(16), child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPanelScreen())),
              child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.purple.shade700, Colors.purple.shade400]), borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Admin Control Panel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('Manage vendors, users & orders', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ])),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
                ])),
            )),
            if (isAdmin) const SizedBox(height: 8),

            // Vendor Dashboard Button
            if (isVendor) Container(color: Colors.white, padding: const EdgeInsets.all(16), child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorDashboardScreen())),
              child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2E8B57), Color(0xFF4CAF50)]), borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const Icon(Icons.store, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Vendor Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('Manage menu, orders & earnings', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ])),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
                ])),
            )),
            if (isVendor) const SizedBox(height: 8),

            // Quick Actions
            Container(color: Colors.white, padding: const EdgeInsets.all(16), child: Row(children: [
              _QuickAction(icon: Icons.receipt_long_outlined, label: 'Orders', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen()))),
              const SizedBox(width: 12),
              _QuickAction(icon: Icons.favorite_border, label: 'Favourites', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavouritesScreen()))),
              const SizedBox(width: 12),
              _QuickAction(icon: Icons.location_on_outlined, label: 'Addresses', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressesScreen()))),
            ])),
            const SizedBox(height: 8),

            // Refund Balance
            Container(color: Colors.white, padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Refund account balance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF2E8B57)), const SizedBox(width: 12), const Text('Refund Account', style: TextStyle(fontWeight: FontWeight.w500))]),
                  Text('৳ ${userData['refundBalance'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ])),
            ])),
            const SizedBox(height: 8),

            // Perks
            Container(color: Colors.white, padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Perks for you', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _PerkTile(icon: Icons.workspace_premium, label: 'Become a pro', iconColor: const Color(0xFF7B2FBE), onTap: () => _msg(context, 'Coming soon!')),
              _PerkTile(icon: Icons.emoji_events_outlined, label: 'LocalEats rewards', iconColor: Colors.amber, onTap: () => _msg(context, 'Coming soon!')),
              _PerkTile(icon: Icons.confirmation_number_outlined, label: 'Vouchers', iconColor: const Color(0xFF2E8B57), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VouchersScreen()))),
              _PerkTile(icon: Icons.card_giftcard_outlined, label: 'Invite friends', iconColor: const Color(0xFFFF7F50), onTap: () => _showInvite(context)),
            ])),
            const SizedBox(height: 8),

            // General
            Container(color: Colors.white, padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('General', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _PerkTile(icon: Icons.payment_outlined, label: 'Payment Methods', iconColor: const Color(0xFF2E8B57), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen()))),
              _PerkTile(icon: Icons.notifications_outlined, label: 'Notifications', iconColor: Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
              _PerkTile(icon: Icons.help_outline, label: 'Help center', iconColor: Colors.blue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()))),
              if (!isVendor) _PerkTile(icon: Icons.business_outlined, label: 'LocalEats for Business', iconColor: const Color(0xFF2E8B57), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VendorRegisterScreen()))),
              _PerkTile(icon: Icons.description_outlined, label: 'Terms & policies', iconColor: Colors.grey, onTap: () => _showTerms(context)),
            ])),
            const SizedBox(height: 8),

            // Logout
            Container(color: Colors.white, padding: const EdgeInsets.all(16), child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                  title: const Text('Log out'),
                  content: const Text('Are you sure?'),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log out', style: TextStyle(color: Colors.red)))],
                ));
                if (confirm == true && context.mounted) {
                  await Provider.of<AuthService>(context, listen: false).signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                }
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Log out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52), side: BorderSide(color: Colors.grey[300]!), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            )),
            const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Version 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)))),
          ]);
        },
      )),
    );
  }

  void _msg(BuildContext context, String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: const Color(0xFF2E8B57)));

  void _showInvite(BuildContext context) => showDialog(context: context, builder: (ctx) => AlertDialog(
    title: const Text('Invite Friends 🎁'),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('Share your referral code:'),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)), child: const Text('LOCALEATS10', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E8B57), letterSpacing: 2))),
    ]),
    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
  ));

  void _showTerms(BuildContext context) => showDialog(context: context, builder: (ctx) => AlertDialog(
    title: const Text('Terms & Policies'),
    content: const SingleChildScrollView(child: Text('LocalEats Terms of Service\n\n1. By using LocalEats, you agree to our terms.\n2. Commission rate is 10% for all vendors.\n3. Delivery fee is ৳40 flat rate.\n4. Refunds within 3-5 business days.')),
    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
  ));
}

class _QuickAction extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(onTap: onTap, child: Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
    child: Column(children: [Icon(icon, color: const Color(0xFF2E8B57), size: 28), const SizedBox(height: 8), Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))]),
  )));
}

class _PerkTile extends StatelessWidget {
  final IconData icon; final String label; final Color iconColor; final VoidCallback onTap;
  const _PerkTile({required this.icon, required this.label, required this.iconColor, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(children: [
      Container(width: 36, height: 36, decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: iconColor, size: 20)),
      const SizedBox(width: 16),
      Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
      Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
    ]),
  ));
}

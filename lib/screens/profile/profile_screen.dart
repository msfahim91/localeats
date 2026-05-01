import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: ListView(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Stack(children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color(0xFFE8F5E9),
                      backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                      child: user?.photoURL == null
                        ? Text((user?.displayName?.isNotEmpty == true) ? user!.displayName![0].toUpperCase() : 'U',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2E8B57)))
                        : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                        child: Container(
                          width: 24, height: 24,
                          decoration: const BoxDecoration(color: Color(0xFF2E8B57), shape: BoxShape.circle),
                          child: const Icon(Icons.edit, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(width: 16),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? 'User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user?.email ?? user?.phoneNumber ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(border: Border.all(color: const Color(0xFF2E8B57)), borderRadius: BorderRadius.circular(20)),
                          child: const Text('Edit Profile', style: TextStyle(color: Color(0xFF2E8B57), fontSize: 12, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
                  )),
                ]),
              ]),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                _QuickAction(icon: Icons.receipt_long_outlined, label: 'Orders', onTap: () {}),
                const SizedBox(width: 12),
                _QuickAction(icon: Icons.favorite_border, label: 'Favourites', onTap: () {}),
                const SizedBox(width: 12),
                _QuickAction(icon: Icons.location_on_outlined, label: 'Addresses', onTap: () {}),
              ]),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Refund account balance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF2E8B57)),
                        const SizedBox(width: 12),
                        const Text('Refund Account', style: TextStyle(fontWeight: FontWeight.w500)),
                      ]),
                      const Text('৳ 0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Perks for you', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _PerkTile(icon: Icons.workspace_premium, label: 'Become a pro', iconColor: const Color(0xFF7B2FBE), onTap: () {}),
                _PerkTile(icon: Icons.emoji_events_outlined, label: 'LocalEats rewards', iconColor: Colors.amber, onTap: () {}),
                _PerkTile(icon: Icons.confirmation_number_outlined, label: 'Vouchers', iconColor: const Color(0xFF2E8B57), onTap: () {}),
                _PerkTile(icon: Icons.card_giftcard_outlined, label: 'Invite friends', iconColor: const Color(0xFFFF7F50), onTap: () {}),
              ]),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('General', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _PerkTile(icon: Icons.help_outline, label: 'Help center', iconColor: Colors.grey, onTap: () {}),
                _PerkTile(icon: Icons.business_outlined, label: 'LocalEats for business', iconColor: Colors.grey, onTap: () {}),
                _PerkTile(icon: Icons.description_outlined, label: 'Terms & policies', iconColor: Colors.grey, onTap: () {}),
              ]),
            ),
            const SizedBox(height: 8),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: OutlinedButton(
                onPressed: () async {
                  await Provider.of<AuthService>(context, listen: false).signOut();
                  if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Log out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              ),
            ),
            const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Version 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)))),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
        child: Column(children: [
          Icon(icon, color: const Color(0xFF2E8B57), size: 28),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
      ),
    ),
  );
}

class _PerkTile extends StatelessWidget {
  final IconData icon; final String label; final Color iconColor; final VoidCallback onTap;
  const _PerkTile({required this.icon, required this.label, required this.iconColor, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 16),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
      ]),
    ),
  );
}

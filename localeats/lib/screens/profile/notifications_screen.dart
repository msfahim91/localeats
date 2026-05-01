import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _orderUpdates = true;
  bool _promotions = true;
  bool _newVendors = false;
  bool _appUpdates = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, title: const Text('Notifications'), elevation: 0),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]), child: Column(children: [
          _NotifTile('Order Updates', 'Get notified about your order status', Icons.delivery_dining_outlined, Colors.green, _orderUpdates, (v) => setState(() => _orderUpdates = v)),
          const Divider(height: 1),
          _NotifTile('Promotions & Offers', 'Deals, discounts and vouchers', Icons.local_offer_outlined, Colors.orange, _promotions, (v) => setState(() => _promotions = v)),
          const Divider(height: 1),
          _NotifTile('New Vendors Nearby', 'When new vendors join your area', Icons.store_outlined, Colors.blue, _newVendors, (v) => setState(() => _newVendors = v)),
          const Divider(height: 1),
          _NotifTile('App Updates', 'New features and improvements', Icons.system_update_outlined, Colors.purple, _appUpdates, (v) => setState(() => _appUpdates = v)),
        ])),
      ]),
    );
  }
}

Widget _NotifTile(String title, String subtitle, IconData icon, Color color, bool value, Function(bool) onChanged) {
  return SwitchListTile(
    secondary: Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
    value: value,
    onChanged: onChanged,
    activeColor: const Color(0xFF2E8B57),
  );
}

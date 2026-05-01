import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';

const List<String> ADMIN_UIDS = ['07On9nFvRHVtZWs6zBRrfdi4Fqq2', 'tCCYJUveGgeXxN2sNWsbaJSaYQL2'];

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});
  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [_DashboardTab(), _VendorsTab(), _UsersTab(), _SettingsTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.store_outlined), label: 'Vendors'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outlined), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
        // Header
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Admin Panel 🛡️', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('LocalEats Control Center', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ]),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle), child: const Icon(Icons.close, size: 20)),
          ),
        ]),
        const SizedBox(height: 16),

        // Stats Row
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (_, us) => StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('vendors').snapshots(),
            builder: (_, vs) {
              final users = us.data?.docs.length ?? 0;
              final allVendors = vs.data?.docs ?? [];
              final pending = allVendors.where((d) => (d.data() as Map)['status'] == 'pending').length;
              final approved = allVendors.where((d) => (d.data() as Map)['status'] == 'approved').length;
              return Row(children: [
                _MiniStat('Users', '$users', Icons.people_outlined, Colors.blue),
                const SizedBox(width: 8),
                _MiniStat('Vendors', '${allVendors.length}', Icons.store_outlined, const Color(0xFF2E8B57)),
                const SizedBox(width: 8),
                _MiniStat('Pending', '$pending', Icons.pending_outlined, Colors.orange, alert: pending > 0),
                const SizedBox(width: 8),
                _MiniStat('Active', '$approved', Icons.verified_outlined, Colors.purple),
              ]);
            },
          ),
        ),
        const SizedBox(height: 16),

        // Pending Approvals
        Row(children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
          const SizedBox(width: 6),
          const Text('Pending Vendor Approvals', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('vendors').where('status', isEqualTo: 'pending').snapshots(),
          builder: (_, snap) {
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [Icon(Icons.check_circle_outline, color: Color(0xFF2E8B57)), SizedBox(width: 8), Text('No pending approvals!', style: TextStyle(color: Colors.grey))]),
            );
            return Column(children: docs.map((doc) => _PendingCard(doc)).toList());
          },
        ),
        const SizedBox(height: 16),

        // Recent Users
        Row(children: [
          const Icon(Icons.person_add_outlined, color: Color(0xFF2E8B57), size: 18),
          const SizedBox(width: 6),
          const Text('Recent Users', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').limit(5).snapshots(),
          builder: (_, snap) {
            final docs = snap.data?.docs ?? [];
            return Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
              child: Column(children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final role = data['role'] ?? 'customer';
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(radius: 18, backgroundColor: const Color(0xFFE8F5E9),
                    child: Text((data['name'] ?? 'U').toString().isNotEmpty ? (data['name'] as String)[0].toUpperCase() : 'U', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E8B57), fontSize: 13))),
                  title: Text(data['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  subtitle: Text(data['email'] ?? '', style: const TextStyle(fontSize: 11)),
                  trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: role == 'vendor' ? const Color(0xFFE8F5E9) : role == 'admin' ? Colors.purple.shade100 : Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(role, style: TextStyle(color: role == 'vendor' ? const Color(0xFF2E8B57) : role == 'admin' ? Colors.purple : Colors.blue, fontSize: 10, fontWeight: FontWeight.bold))),
                );
              }).toList()),
            );
          },
        ),
      ])),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value; final IconData icon; final Color color; final bool alert;
  const _MiniStat(this.label, this.value, this.icon, this.color, {this.alert = false});
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(
      color: alert ? color.withOpacity(0.08) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: alert ? Border.all(color: color, width: 1.5) : null,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
    child: Column(children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
    ]),
  ));
}

class _PendingCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  const _PendingCard(this.doc);

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)), child: const Text('PENDING', style: TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 4),
        Text('${data['category']} • ${data['phone']} • ${data['address']}', style: TextStyle(color: Colors.grey[600], fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('vendors').doc(doc.id).update({'status': 'approved', 'isVerified': true, 'isActive': true});
              try { await FirebaseFirestore.instance.collection('users').doc(doc.id).update({'role': 'vendor'}); } catch (_) {}
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Vendor Approved!'), backgroundColor: Color(0xFF2E8B57)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, minimumSize: const Size(0, 34), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Approve', style: TextStyle(fontSize: 12)),
          )),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('vendors').doc(doc.id).update({'status': 'rejected', 'isActive': false});
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Rejected'), backgroundColor: Colors.red));
            },
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), minimumSize: const Size(0, 34), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Reject', style: TextStyle(fontSize: 12)),
          )),
        ]),
      ]),
    );
  }
}

class _VendorsTab extends StatefulWidget {
  const _VendorsTab();
  @override
  State<_VendorsTab> createState() => _VendorsTabState();
}

class _VendorsTabState extends State<_VendorsTab> with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F9FA),
    appBar: AppBar(
      backgroundColor: Colors.purple, foregroundColor: Colors.white,
      title: const Text('Vendor Management'), automaticallyImplyLeading: false,
      bottom: TabBar(controller: _tab, indicatorColor: Colors.white, labelColor: Colors.white, unselectedLabelColor: Colors.white60,
        tabs: const [Tab(text: 'All'), Tab(text: 'Pending'), Tab(text: 'Approved')]),
    ),
    body: TabBarView(controller: _tab, children: [_VendorList(filter: null), _VendorList(filter: 'pending'), _VendorList(filter: 'approved')]),
  );
}

class _VendorList extends StatelessWidget {
  final String? filter;
  const _VendorList({this.filter});

  @override
  Widget build(BuildContext context) {
    Query q = FirebaseFirestore.instance.collection('vendors');
    if (filter != null) q = q.where('status', isEqualTo: filter);
    return StreamBuilder<QuerySnapshot>(
      stream: q.snapshots(),
      builder: (_, snap) {
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text('No vendors', style: TextStyle(color: Colors.grey)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';
            final isActive = data['isActive'] ?? false;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text(data['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(color: status == 'approved' ? const Color(0xFFE8F5E9) : status == 'pending' ? Colors.orange.shade100 : Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Text(status.toUpperCase(), style: TextStyle(color: status == 'approved' ? const Color(0xFF2E8B57) : status == 'pending' ? Colors.orange : Colors.red, fontSize: 9, fontWeight: FontWeight.bold))),
                ]),
                Text('${data['category']} • ${data['phone']}', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                Text(data['address'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                const SizedBox(height: 8),
                Row(children: [
                  if (status == 'pending') ...[
                    Expanded(child: ElevatedButton(onPressed: () async { await FirebaseFirestore.instance.collection('vendors').doc(docs[i].id).update({'status': 'approved', 'isVerified': true, 'isActive': true}); try { await FirebaseFirestore.instance.collection('users').doc(docs[i].id).update({'role': 'vendor'}); } catch (_) {} }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, minimumSize: const Size(0, 32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Approve', style: TextStyle(fontSize: 12)))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton(onPressed: () async { await FirebaseFirestore.instance.collection('vendors').doc(docs[i].id).update({'status': 'rejected'}); }, style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), minimumSize: const Size(0, 32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Reject', style: TextStyle(fontSize: 12)))),
                  ],
                  if (status == 'approved') Expanded(child: OutlinedButton(onPressed: () async { await FirebaseFirestore.instance.collection('vendors').doc(docs[i].id).update({'isActive': !isActive}); }, style: OutlinedButton.styleFrom(foregroundColor: isActive ? Colors.orange : const Color(0xFF2E8B57), side: BorderSide(color: isActive ? Colors.orange : const Color(0xFF2E8B57)), minimumSize: const Size(0, 32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text(isActive ? 'Deactivate' : 'Activate', style: const TextStyle(fontSize: 12)))),
                  if (status == 'rejected') Expanded(child: ElevatedButton(onPressed: () async { await FirebaseFirestore.instance.collection('vendors').doc(docs[i].id).update({'status': 'approved', 'isVerified': true, 'isActive': true}); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E8B57), foregroundColor: Colors.white, minimumSize: const Size(0, 32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text('Re-Approve', style: TextStyle(fontSize: 12)))),
                ]),
              ]),
            );
          },
        );
      },
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F9FA),
    appBar: AppBar(backgroundColor: Colors.purple, foregroundColor: Colors.white, title: const Text('User Management'), automaticallyImplyLeading: false),
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (_, snap) {
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text('No users', style: TextStyle(color: Colors.grey)));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final role = data['role'] ?? 'customer';
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
              child: Row(children: [
                CircleAvatar(radius: 20, backgroundColor: const Color(0xFFE8F5E9),
                  child: Text((data['name'] ?? 'U').toString().isNotEmpty ? (data['name'] as String)[0].toUpperCase() : 'U', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E8B57), fontSize: 14))),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(data['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(data['email'] ?? data['phone'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: role == 'vendor' ? const Color(0xFFE8F5E9) : role == 'admin' ? Colors.purple.shade100 : Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text(role, style: TextStyle(color: role == 'vendor' ? const Color(0xFF2E8B57) : role == 'admin' ? Colors.purple : Colors.blue, fontSize: 10, fontWeight: FontWeight.bold))),
              ]),
            );
          },
        );
      },
    ),
  );
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F9FA),
    appBar: AppBar(backgroundColor: Colors.purple, foregroundColor: Colors.white, title: const Text('App Settings'), automaticallyImplyLeading: false),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      _section('App Configuration', [
        _tile('Delivery Fee', '৳40', Icons.delivery_dining_outlined, () => _edit(context, 'Delivery Fee', '40')),
        _tile('Commission Rate', '10%', Icons.percent, () => _edit(context, 'Commission Rate', '10')),
        _tile('Delivery Radius', '5 km', Icons.radar, () => _edit(context, 'Delivery Radius', '5')),
        _tile('Min Order Amount', '৳50', Icons.shopping_bag_outlined, () => _edit(context, 'Min Order', '50')),
      ]),
      const SizedBox(height: 12),
      _section('Promo Codes', [
        _tile('LOCALEATS10', '10% off — Active', Icons.confirmation_number_outlined, () {}),
        _tile('Add New Promo', 'Create promo code', Icons.add_circle_outline, () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon!'), backgroundColor: Colors.purple))),
      ]),
      const SizedBox(height: 12),
      _section('Admins', [
        _tile('MS Fahim (msfahim71291)', 'Super Admin', Icons.admin_panel_settings_outlined, () {}),
        _tile('MS Fahim (msfahim71292)', 'Admin', Icons.admin_panel_settings_outlined, () {}),
      ]),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade200)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Danger Zone', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
            },
            icon: const Icon(Icons.logout, color: Colors.red, size: 18),
            label: const Text('Sign Out from Admin', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          )),
        ]),
      ),
    ]),
  );

  Widget _section(String title, List<Widget> tiles) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 6), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
      ...tiles,
    ]),
  );

  Widget _tile(String title, String value, IconData icon, VoidCallback onTap) => InkWell(
    onTap: onTap,
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), child: Row(children: [
      Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.purple.withOpacity(0.08), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.purple, size: 16)),
      const SizedBox(width: 10),
      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
      Text(value, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      const SizedBox(width: 6),
      Icon(Icons.arrow_forward_ios, size: 11, color: Colors.grey[400]),
    ])),
  );

  void _edit(BuildContext context, String title, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text('Edit $title', style: const TextStyle(fontSize: 16)),
      content: TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: 'Enter new value', filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title updated!'), backgroundColor: Colors.purple)); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white), child: const Text('Save')),
      ],
    ));
  }
}

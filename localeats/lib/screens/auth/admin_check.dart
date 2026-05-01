import 'package:firebase_auth/firebase_auth.dart';

// এখানে তোমার Firebase UID দাও
const String adminUID = 'PUT_YOUR_UID_HERE';

bool isAdmin() {
  return FirebaseAuth.instance.currentUser?.uid == adminUID;
}

// === FILE: lib/services/user_service.dart ===
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/user_model.dart';

class UserService {
  final _col = FirebaseFirestore.instance.collection('users');

  // 🔹 Streams
  Stream<List<UserModel>> streamAllUsers() {
    return _col.orderBy('created_at', descending: true).snapshots().map(
          (s) => s.docs.map((d) => UserModel.fromDoc(d)).toList(),
        );
  }

  Stream<List<UserModel>> streamAdmins() {
    return _col.where('role', isEqualTo: 'Admin').snapshots().map(
          (s) => s.docs.map((d) => UserModel.fromDoc(d)).toList(),
        );
  }

  Stream<List<UserModel>> streamCustomers() {
    return _col.where('role', isEqualTo: 'User').snapshots().map(
          (s) => s.docs.map((d) => UserModel.fromDoc(d)).toList(),
        );
  }

  // 🔹 Current user role
  Future<String?> getCurrentUserRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _col.doc(uid).get();
    return doc.exists ? (doc.data()!['role'] as String?) : null;
  }

  // 🔹 CRUD operations
  Future<void> addUserFirestoreOnly({required UserModel user}) async {
    await _col.doc(user.id).set(user.toMap());
  }

  Future<void> deleteUserDoc(String id) async {
    await _col.doc(id).delete();
  }

  Future<void> updateUser(UserModel updated) async {
    await _col.doc(updated.id).update(updated.toMap());
  }

  Future<void> toggleActive(String id, bool active) async {
    await _col.doc(id).update({'isActive': active});
  }

  // 🔹 Custom: logout user (for Admins)
  Future<void> logoutUser(String id) async {
    // Simply mark user as inactive for simulation
    await _col.doc(id).update({'isActive': false});

    // Optional: if you want to sign out admin from Firebase Auth itself
    // final current = FirebaseAuth.instance.currentUser;
    // if (current != null && current.uid == id) {
    //   await FirebaseAuth.instance.signOut();
    // }
  }
}

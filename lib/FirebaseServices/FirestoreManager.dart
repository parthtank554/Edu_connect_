import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addUserToFirestore(
      String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(uid).set(userData);
    } catch (e) {
      rethrow; // Handle the error in the UI
    }
  }
  Future<Map<String, dynamic>?> fetchUserData() async {
    try {
      String? uid = _auth.currentUser?.uid;
      if (uid != null) {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
        if (userDoc.exists) {
          return userDoc.data() as Map<String, dynamic>;
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null;
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserDocument({User user, String email}) {
    _db.collection('users').doc(user.uid).set({
      "uid": user.uid,
      "email": email,
    });
  }

  Future<void> addEvent({User user, Map<String, dynamic> event}) {
    _db.collection('users').doc(user.uid).collection('events').add(
          event,
        );
  }

  Future<void> deleteEvent({User user, int millis}) {
    _db
        .collection('users')
        .doc(user.uid)
        .collection('events')
        .where('millis', isEqualTo: millis)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) => doc.reference.delete());
    });
  }
}

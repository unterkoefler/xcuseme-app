import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xcuseme/models/event.dart';
import 'package:xcuseme/models/settings.dart';
import 'package:xcuseme/database.dart';

class FirestoreService {
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserDocument({User user, String email}) async {
    await _db.collection('users').doc(user.uid).set({
      "uid": user.uid,
      "email": email,
    });
    _uploadExistingData(user);
  }

  Future<void> _uploadExistingData(User user) async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    List<Map<String, dynamic>> rows = await dbHelper.queryAllRows();
    rows.forEach((row) {
      _eventsRef(user).add(row);
    });
  }

  Stream<UserSettings> settingsStream({User user}) {
    return _db.collection('users').doc(user.uid).snapshots().map((snapshot) {
      return UserSettings.fromMap(snapshot.data());
    });
  }

  Future<void> updateSettings({User user, UserSettings settings}) {
    _db.collection('users').doc(user.uid).update(settings.toMap());
  }

  Stream<List<Event>> eventStream({User user}) {
    return _eventsRef(user).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Event.fromMap(doc.data())).toList();
    });
  }

  Future<void> addEvent({User user, Event event}) {
    _eventsRef(user).add(
      event.toMap(),
    );
  }

  Future<Event> updateEvent(
      {User user,
      Event oldEvent,
      DateTime newDate,
      String newDescription}) async {
    Event newEvent = oldEvent.update(newDate, newDescription);
    await _eventsRef(user)
        .where('millis', isEqualTo: oldEvent.millis)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) => doc.reference.update(newEvent.toMap()));
    });
    return newEvent;
  }

  Future<void> deleteEvent({User user, Event event}) {
    _eventsRef(user)
        .where('millis', isEqualTo: event.millis)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((doc) => doc.reference.delete());
    });
  }

  CollectionReference _eventsRef(User user) {
    return _db.collection('users').doc(user.uid).collection('events');
  }
}

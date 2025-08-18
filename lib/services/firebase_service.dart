import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  FirebaseService._();
  static final instance = FirebaseService._();

  final _db = FirebaseFirestore.instance;

  Future<String> ping() async {
    final doc = _db.collection('health').doc('ping');
    await doc.set({'ts': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    final snap = await doc.get();
    final ts = (snap.data() ?? {})['ts'];
    return 'ok:${ts ?? 'null'}';
  }
}

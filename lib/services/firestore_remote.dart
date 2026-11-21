import 'package:cloud_firestore/cloud_firestore.dart';

import 'data_store.dart';

/// The club's shared data in Cloud Firestore: each collection lives at
/// `clubs/{clubId}/{collection}`, one document per item.
class FirestoreRemote implements RemoteCollections {
  final FirebaseFirestore firestore;
  final String clubId;

  FirestoreRemote({FirebaseFirestore? firestore, this.clubId = 'default'})
      : firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String name) =>
      firestore.collection('clubs').doc(clubId).collection(name);

  @override
  Stream<Items> watch(String collection) => _collection(collection).snapshots().map(
        (snapshot) => {for (final doc in snapshot.docs) doc.id: doc.data()},
      );

  @override
  Future<void> write(String collection, Map<String, Map<String, dynamic>?> changes) async {
    // Firestore allows at most 500 writes per batch.
    const batchSize = 450;
    final entries = changes.entries.toList();
    for (var start = 0; start < entries.length; start += batchSize) {
      final batch = firestore.batch();
      for (final e in entries.skip(start).take(batchSize)) {
        final doc = _collection(collection).doc(e.key);
        if (e.value == null) {
          batch.delete(doc);
        } else {
          batch.set(doc, e.value!);
        }
      }
      await batch.commit();
    }
  }

  /// Whether the club has any shared data yet.
  Future<bool> hasAnyData(Iterable<String> collections) async {
    for (final c in collections) {
      final snapshot = await _collection(c).limit(1).get();
      if (snapshot.docs.isNotEmpty) return true;
    }
    return false;
  }
}

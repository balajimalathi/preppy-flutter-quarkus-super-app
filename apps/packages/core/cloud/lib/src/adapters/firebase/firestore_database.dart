import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../contracts/cloud_collection.dart';
import '../../contracts/cloud_database.dart';
import '../../contracts/cloud_storage.dart';
import 'firebase_storage_adapter.dart';
import 'firestore_collection.dart';

/// Firebase (Firestore + Firebase Storage) implementation of [CloudDatabase].
final class FirestoreDatabase implements CloudDatabase {
  FirestoreDatabase({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage = FirebaseStorageAdapter(storage: storage);

  final FirebaseFirestore _firestore;
  final FirebaseStorageAdapter _storage;

  @override
  CloudCollection<T> collection<T>(
    String name,
    T Function(Map<String, dynamic> json) fromJson,
    Map<String, dynamic> Function(T value) toJson,
  ) {
    return FirestoreCollection<T>(
      collectionName: name,
      fromJson: fromJson,
      toJson: toJson,
      reference: _firestore.collection(name),
    );
  }

  @override
  CloudStorage get storage => _storage;
}

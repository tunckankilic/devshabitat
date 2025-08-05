import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore;

  CollectionReference getCollection(String path) {
    return _firestore.collection(path);
  }

  Future<DocumentSnapshot> getDocument(String collection, String documentId) {
    return _firestore.collection(collection).doc(documentId).get();
  }

  Future<void> setDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) {
    return _firestore.collection(collection).doc(documentId).set(data);
  }

  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) {
    return _firestore.collection(collection).doc(documentId).update(data);
  }

  Future<void> deleteDocument(String collection, String documentId) {
    return _firestore.collection(collection).doc(documentId).delete();
  }

  Query<Map<String, dynamic>> query(String collection) {
    return _firestore.collection(collection);
  }
}

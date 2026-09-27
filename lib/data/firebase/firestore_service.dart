import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

/// Abstraction layer over Cloud Firestore.
///
/// All Firestore reads/writes go through this service so that:
/// 1. UI never directly touches Firestore.
/// 2. We can swap in a mock/local implementation for testing.
/// 3. Firebase import issues don't cascade throughout the codebase.
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService() : _firestore = FirebaseFirestore.instance;

  // ─── Generic CRUD ───────────────────────────────────────────

  /// Get a single document by path.
  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String docId,
  ) async {
    final doc = await _firestore.collection(collection).doc(docId).get();
    return doc.data();
  }

  /// Listen to a single document by path.
  Stream<Map<String, dynamic>?> streamDocument(
    String collection,
    String docId,
  ) {
    return _firestore
        .collection(collection)
        .doc(docId)
        .snapshots()
        .map((doc) => doc.data());
  }

  /// Get all documents in a collection (optionally filtered).
  Future<List<Map<String, dynamic>>> getCollection(
    String collection, {
    String? whereField,
    dynamic isEqualTo,
    String? orderByField,
    bool descending = false,
    int? limit,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);
    if (whereField != null) {
      query = query.where(whereField, isEqualTo: isEqualTo);
    }
    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  /// Set (create or overwrite) a document.
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    await _firestore
        .collection(collection)
        .doc(docId)
        .set(data, SetOptions(merge: merge));
  }

  /// Update specific fields of a document.
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  /// Delete a document.
  Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  // ─── User-scoped helpers ────────────────────────────────────

  /// Get documents from a user's sub-collection.
  Future<List<Map<String, dynamic>>> getUserSubCollection(
    String userId,
    String subCollection, {
    String? orderByField,
    bool descending = false,
    int? limit,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(subCollection);
    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  /// Stream documents from a user's sub-collection in real time.
  Stream<List<Map<String, dynamic>>> streamUserSubCollection(
    String userId,
    String subCollection, {
    String? orderByField,
    bool descending = false,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(subCollection);
    if (orderByField != null) {
      query = query.orderBy(orderByField, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    return query.snapshots().map(
          (snapshot) => snapshot.docs.map((d) => d.data()).toList(),
        );
  }

  /// Set a document in a user's sub-collection.
  Future<void> setUserSubDocument(
    String userId,
    String subCollection,
    String docId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(subCollection)
        .doc(docId)
        .set(data, SetOptions(merge: merge));
  }

  /// Delete a document from a user's sub-collection.
  Future<void> deleteUserSubDocument(
    String userId,
    String subCollection,
    String docId,
  ) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(subCollection)
        .doc(docId)
        .delete();
  }

  /// Batch delete all documents in a user's sub-collection.
  Future<void> deleteUserSubCollection(
    String userId,
    String subCollection,
  ) async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(subCollection)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// Check if a document exists in a user's sub-collection.
  Future<bool> userSubDocumentExists(
    String userId,
    String subCollection,
    String docId,
  ) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(subCollection)
        .doc(docId)
        .get();
    return doc.exists;
  }
}

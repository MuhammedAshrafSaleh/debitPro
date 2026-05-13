// lib/features/clients/data/datasources/firestore_client_datasource.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/models/client_model.dart';
import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/client_repository.dart';

abstract class ClientRemoteDataSource {
  Stream<List<ClientModel>> watchClients(ClientFilter filter);
  Future<ClientModel> getClient(String id);
  Future<ClientModel> addClient(AddClientParams params);
  Future<ClientModel> editClient(EditClientParams params);
  Future<void> deleteClient(String id);
}

class ClientRemoteDataSourceImpl implements ClientRemoteDataSource {
  ClientRemoteDataSourceImpl(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final _log = Logger();

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _clientsRef =>
      _firestore.collection(FirestorePaths.clients(_uid));

  @override
  Stream<List<ClientModel>> watchClients(ClientFilter filter) {
    // Filter is applied client-side in the cubit to avoid composite index requirements.
    return _clientsRef
        .orderBy('createdAt', descending: true)
        .limit(500)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => ClientModel.fromFirestore(doc)).toList(),
        );
  }

  @override
  Future<ClientModel> getClient(String id) async {
    try {
      final doc = await _clientsRef.doc(id).get();
      if (!doc.exists) {
        throw ServerException('العميل غير موجود');
      }
      return ClientModel.fromFirestore(doc);
    } on ServerException {
      rethrow;
    } catch (e) {
      _log.e('getClient', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ClientModel> addClient(AddClientParams params) async {
    try {
      final docRef = _clientsRef.doc();
      final now = DateTime.now();
      final model = ClientModel(
        id: docRef.id,
        fullName: params.fullName,
        phone: params.phone,
        gender: params.gender,
        documentationType: params.documentationType,
        clientType: params.clientType,
        notes: params.notes,
        totalPaid: 0,
        totalRemaining: 0,
        activeDebtsCount: 0,
        paymentQualityScore: 0,
        onTimePaymentsCount: 0,
        totalDuePaymentsCount: 0,
        createdAt: now,
        updatedAt: now,
      );

      final uid = _uid; // capture before entering transaction
      await _firestore.runTransaction((tx) async {
        tx.set(docRef, model.toFirestore());
        final allTimeRef = _firestore.doc(FirestorePaths.allTimeAgg(uid));
        tx.set(
          allTimeRef,
          {'totalClients': FieldValue.increment(1), 'updatedAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true),
        );
      });

      return model;
    } catch (e) {
      _log.e('addClient', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ClientModel> editClient(EditClientParams params) async {
    try {
      final docRef = _clientsRef.doc(params.id);
      final update = {
        'fullName': params.fullName,
        'phone': params.phone,
        'gender': params.gender.name,
        'documentationType': params.documentationType.name,
        'clientType': params.clientType.name,
        'notes': params.notes,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await docRef.update(update);
      final doc = await docRef.get();
      return ClientModel.fromFirestore(doc);
    } catch (e) {
      _log.e('editClient', error: e);
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteClient(String id) async {
    try {
      await _firestore.runTransaction((tx) async {
        tx.delete(_clientsRef.doc(id));
        final allTimeRef = _firestore.doc(FirestorePaths.allTimeAgg(_uid));
        tx.set(
          allTimeRef,
          {'totalClients': FieldValue.increment(-1), 'updatedAt': FieldValue.serverTimestamp()},
          SetOptions(merge: true),
        );
      });
    } catch (e) {
      _log.e('deleteClient', error: e);
      throw ServerException(e.toString());
    }
  }
}

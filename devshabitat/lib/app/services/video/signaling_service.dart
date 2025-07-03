import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:devshabitat/app/models/video/call_model.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class SignalingService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference _callsCollection;
  late final CollectionReference _signalsCollection;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  @override
  void onInit() {
    super.onInit();
    _callsCollection = _firestore.collection('calls');
    _signalsCollection = _firestore.collection('signals');
  }

  Stream<CallModel> watchCall(String callId) {
    return _callsCollection.doc(callId).snapshots().map(
          (snapshot) => CallModel.fromJson(
            snapshot.data() as Map<String, dynamic>,
          ),
        );
  }

  Future<void> createCall(CallModel call) async {
    await _callsCollection.doc(call.id).set(call.toJson());
  }

  Future<void> updateCallStatus(String callId, CallStatus status) async {
    await _callsCollection.doc(callId).update({'status': status.toString()});
  }

  Future<void> endCall(String callId) async {
    await _callsCollection.doc(callId).update({
      'status': CallStatus.ended.toString(),
      'endTime': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getSignals(String callId) {
    return _signalsCollection
        .where('callId', isEqualTo: callId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList());
  }

  Future<void> sendSignal({
    required String callId,
    required String fromUserId,
    required String toUserId,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    await _signalsCollection.add({
      'callId': callId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'type': type,
      'data': data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> cleanupSignals(String callId) async {
    final batch = _firestore.batch();
    final signals =
        await _signalsCollection.where('callId', isEqualTo: callId).get();

    for (var doc in signals.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<List<CallModel>> getRecentCalls(String userId,
      {int limit = 20}) async {
    final snapshot = await _callsCollection
        .where('participants', arrayContains: userId)
        .orderBy('startTime', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => CallModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Stream<Map<String, dynamic>> get onSignalingMessage =>
      _messageController.stream;

  Future<void> joinRoom({
    required String roomId,
    required String userId,
    required bool isInitiator,
  }) async {
    // Odaya katılım bilgisini kaydet
    await _firestore.collection('calls').doc(roomId).update({
      'participants': FieldValue.arrayUnion([userId]),
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    // Sinyal mesajlarını dinle
    _firestore
        .collection('calls')
        .doc(roomId)
        .collection('signaling')
        .where('targetId', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final message = change.doc.data()!;
          _messageController.add(message);

          // İşlenmiş mesajı sil
          change.doc.reference.delete();
        }
      }
    });
  }

  Future<void> sendOffer({
    required String roomId,
    required String userId,
    required String targetId,
    required RTCSessionDescription offer,
  }) async {
    await _firestore
        .collection('calls')
        .doc(roomId)
        .collection('signaling')
        .add({
      'type': 'offer',
      'userId': userId,
      'targetId': targetId,
      'sdp': offer.sdp,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendAnswer({
    required String roomId,
    required String userId,
    required String targetId,
    required RTCSessionDescription answer,
  }) async {
    await _firestore
        .collection('calls')
        .doc(roomId)
        .collection('signaling')
        .add({
      'type': 'answer',
      'userId': userId,
      'targetId': targetId,
      'sdp': answer.sdp,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendIceCandidate({
    required String roomId,
    required String userId,
    required String targetId,
    required RTCIceCandidate candidate,
  }) async {
    await _firestore
        .collection('calls')
        .doc(roomId)
        .collection('signaling')
        .add({
      'type': 'ice-candidate',
      'userId': userId,
      'targetId': targetId,
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateParticipantState({
    required String roomId,
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    await _firestore
        .collection('calls')
        .doc(roomId)
        .collection('participants')
        .doc(userId)
        .update(updates);
  }

  Future<void> leaveRoom({
    required String roomId,
    required String userId,
  }) async {
    // Katılımcıyı odadan çıkar
    await _firestore.collection('calls').doc(roomId).update({
      'participants': FieldValue.arrayRemove([userId]),
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    // Katılımcı durumunu sil
    await _firestore
        .collection('calls')
        .doc(roomId)
        .collection('participants')
        .doc(userId)
        .delete();

    // İşlenmemiş sinyal mesajlarını temizle
    final messages = await _firestore
        .collection('calls')
        .doc(roomId)
        .collection('signaling')
        .where('targetId', isEqualTo: userId)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.delete();
    }
  }

  void dispose() {
    _messageController.close();
  }
}

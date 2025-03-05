// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_testing/features/auth/controller/auth_controller.dart';
import 'package:vc_testing/features/call/repository/call_repository.dart';
import 'package:vc_testing/models/call.dart';
import 'package:vc_testing/old_noti_service.dart';

final callControllerProvider = Provider(
  (ref) {
    final callRepository = ref.read(callRepositoryProvider);
    return CallController(
      callRepository: callRepository,
      auth: FirebaseAuth.instance,
      ref: ref,
      notificationsService: ref.read(notiServiceProvider),
    );
  },
);

class CallController {
  final CallRepository callRepository;
  final ProviderRef ref;
  final FirebaseAuth auth;
  final NotificationsService notificationsService;
  CallController({
    required this.callRepository,
    required this.ref,
    required this.auth,
    required this.notificationsService,
  });

  Stream<DocumentSnapshot> get callStream => callRepository.callStream;

  void makeCall({
    required BuildContext context,
    required String receiverName,
    required String receiverUid,
    required String receiverProfilePic,
    required String receiverDeviceToken,
    required bool isGroupChat,
  }) async {
    ref.read(userDataAuthProvider).whenData((value) async {
      // generate calll id
      String callId = Random().nextInt(10000).toString();

      Call senderCallData = Call(
        callerId: auth.currentUser!.uid,
        callerName: value!.name,
        callerPic: value.profilePic,
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverPic: receiverProfilePic,
        callId: callId,
        hasDialled: true,
      );

      Call recieverCallData = Call(
        callerId: auth.currentUser!.uid,
        callerName: value.name,
        callerPic: value.profilePic,
        receiverId: receiverUid,
        receiverName: receiverName,
        receiverPic: receiverProfilePic,
        callId: callId,
        hasDialled: false,
      );
      await notificationsService.sendNotification(
        title: senderCallData.callerName,
        body: senderCallData.callerName,
        callerName: recieverCallData.callerName,
        callerPhone: "Custom phone number",
        deviceToken: receiverDeviceToken,
        roomId: callId
      );
      await callRepository.makeCall(
        senderCallData,
        context,
        recieverCallData,
        callId,
      );
    });
  }

  void endCall(
    String callerId,
    String receiverId,
    BuildContext context,
  ) {
    callRepository.endCall(callerId, receiverId, context);
  }
}
//
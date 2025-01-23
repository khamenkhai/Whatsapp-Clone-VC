import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:vc_testing/features/call/screens/call_screen.dart';

class CallKitService {
  // Function to show incoming call
  Future<void> showIncomingCall({
    required String roomId,
    required String callerName,
    required String localUserID,
    required BuildContext context,
  }) async {
    final params = CallKitParams(
      id: roomId,
      nameCaller: '${callerName}',
      appName: 'Callkit',
      avatar: 'https://i.pravatar.cc/100',
      handle: '0123456789',
      type: 0, // Audio call
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),

      extra: <String, dynamic>{'userId': '1a2b3c4d'},
      headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        backgroundUrl: 'assets/test.png',
        actionColor: '#4CAF50',
        textColor: '#ffffff',
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: '',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    // Show the incoming call screen
    await FlutterCallkitIncoming.showCallkitIncoming(params);

    // Listen to call events (accept, decline, end)
    _listenToCallEvents(
      context: context,
      localUserID: localUserID,
      localUserName: callerName,
      roomId: roomId,
    );
  }

  // Helper function to get a unique UUID for each call


  // Function to listen to call events
  void _listenToCallEvents({
    required BuildContext context,
    required String localUserID,
    required String localUserName,
    required String roomId,
  }) {
    // Listen for incoming call events
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      switch (event!.event) {
        case Event.actionCallIncoming:
          // TODO: received an incoming call
          break;
        case Event.actionCallStart:
          // TODO: started an outgoing call
          // TODO: show screen calling in Flutter
          break;
        case Event.actionCallAccept:
          print("testing hello world");
          _navigateToCallScreen(
            context: context,
            localUserID: localUserID,
            localUserName: localUserName,
            roomId: roomId,
          );
          // TODO: show screen calling in Flutter
          // Does not work for Android in terminated state
          // final activeCall = await IncomingCallHelper.getIncomingActiveCall();
          // if (activeCall != null) {
          //   logger.d('Navigating to callRoute');
          //   getIt<AppRouter>().navigate(
          //     AgoraCallRoute(callData: activeCall.callData),
          //   );
          // }
          break;
        case Event.actionCallDecline:
          // TODO: declined an incoming call
          break;
        case Event.actionCallEnded:
          // // End the call
          // AgoraAvCallController.instance.endCall();
          break;
        case Event.actionCallTimeout:
          // TODO: missed an incoming call
          break;
        case Event.actionCallCallback:
          // TODO: only Android - click action `Call back` from missed call notification
          break;
        case Event.actionCallToggleHold:
          // TODO: only iOS
          break;
        case Event.actionCallToggleMute:
          // Only iOS - mute or unmute the local audio
          // if (mute) {
          //   AgoraAvCallController.instance.unMuteLocalAudio();
          //   mute = false;
          // } else {
          //   AgoraAvCallController.instance.muteLocalAudio();
          //   mute = true;
          // }
          break;
        case Event.actionCallToggleDmtf:
          // TODO: only iOS
          break;
        case Event.actionCallToggleGroup:
          // TODO: only iOS
          break;
        case Event.actionCallToggleAudioSession:
          // TODO: only iOS
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
          // TODO: only iOS
          break;
        case Event.actionCallCustom:
          // TODO: for custom action
          break;
      }
    });
    // FlutterCallkitIncoming.onEvent.listen(
    //   (event) async {
    //     print("event : ${event}");
    //     switch (event) {
    //       case CallEvent.accept:
    //         // Handle call acceptance
    //         _navigateToCallScreen(context);
    //         break;

    //       case CallEvent.decline:
    //         // Handle call decline if needed
    //         break;

    //       case CallEvent.end:
    //         // Handle call end if needed
    //         break;

    //       default:
    //         break;
    //     }
    //   },
    // );
  }

  // Navigate to call screen on acceptance
  void _navigateToCallScreen({
    required BuildContext context,
    required String localUserID,
    required String localUserName,
    required String roomId,
  }) {
    // You can replace this with your actual call screen navigation logic
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CallScreen(
                localUserID: localUserID,
                localUserName: localUserName,
                roomId: roomId,
              )),
    );
  }
}

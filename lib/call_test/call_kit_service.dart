import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:vc_testing/features/call/screens/call_screen.dart';

class CallKitService {
  // Function to show incoming call
  Future<void> showIncomingCall({
    required String roomId,
    required String callerName,
    required String localUserID,
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
      localUserID: localUserID,
      localUserName: callerName,
      roomId: roomId,
    );
  }

  // Function to listen to call events
  void _listenToCallEvents({
    required String localUserID,
    required String localUserName,
    required String roomId,
  }) {
    // Listen for incoming call events
    FlutterCallkitIncoming.onEvent.listen(
      (CallEvent? event) async {
        switch (event!.event) {
          case Event.actionCallIncoming:
            break;
          case Event.actionCallStart:
            break;
          case Event.actionCallAccept:
            print("testing hello world");
            _navigateToCallScreen(
              localUserID: localUserID,
              localUserName: localUserName,
              roomId: roomId,
            );

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
            break;
          case Event.actionCallEnded:
            // // End the call
            // AgoraAvCallController.instance.endCall();
            break;
          case Event.actionCallTimeout:
            break;
          case Event.actionCallCallback:
            break;
          case Event.actionCallToggleHold:
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
            break;
          case Event.actionCallToggleGroup:
            break;
          case Event.actionCallToggleAudioSession:
            break;
          case Event.actionDidUpdateDevicePushTokenVoip:
            break;
          case Event.actionCallCustom:
            break;
        }
      },
    );
  }

  // Navigate to call screen on acceptance
  void _navigateToCallScreen({
    required String localUserID,
    required String localUserName,
    required String roomId,
  }) {
    // You can replace this with your actual call screen navigation logic
    Get.to(
      CallScreen(
        localUserID: localUserID,
        localUserName: localUserName,
        roomId: roomId,
      ),
    );
  }
}

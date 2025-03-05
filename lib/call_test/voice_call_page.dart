import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vc_testing/call_test/utils/zegocloud_token.dart';
import 'package:vc_testing/call_test/widgets/buttom_rows.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'key_center.dart';

class VoiceCallPage extends StatefulWidget {
  const VoiceCallPage({
    super.key,
    required this.localUserID,
    required this.localUserName,
    required this.roomID,
  });

  final String localUserID;
  final String localUserName;
  final String roomID;

  @override
  State<VoiceCallPage> createState() => _VoiceCallPageState();
}

class _VoiceCallPageState extends State<VoiceCallPage> {
  bool speakerHigh = true;
  bool isMuted = false;
  final primaryColor = Color(0xffE77917);

  @override
  void initState() {
    super.initState();
    startListenEvent();
    loginRoom();
  }

  @override
  void dispose() {
    stopListenEvent();
    logoutRoom();
    super.dispose();
  }

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      print("Camera permission granted!");
    } else if (status.isDenied) {
      print("Camera permission denied.");
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          // Bottom Row for call controls (Mute, Speaker, End Call)
          _buttonRows(context),
        ],
      ),
    );
  }

  // login room
  Future<ZegoRoomLoginResult> loginRoom() async {
    final user = ZegoUser(widget.localUserID, widget.localUserName);
    final roomID = widget.roomID;

    ZegoRoomConfig roomConfig = ZegoRoomConfig.defaultConfig()
      ..isUserStatusNotify = true;

    if (kIsWeb) {
      roomConfig.token = ZegoTokenUtils.generateToken(appID, serverSecret, widget.localUserID);
    }

    return ZegoExpressEngine.instance
        .loginRoom(roomID, user, config: roomConfig)
        .then((ZegoRoomLoginResult loginRoomResult) {
      debugPrint('loginRoom: errorCode:${loginRoomResult.errorCode}');
      if (loginRoomResult.errorCode == 0) {
        startPublish();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('loginRoom failed: ${loginRoomResult.errorCode}')));
      }
      return loginRoomResult;
    });
  }

  Future<ZegoRoomLogoutResult> logoutRoom() async {
    stopPublish();
    return ZegoExpressEngine.instance.logoutRoom(widget.roomID);
  }

  void startListenEvent() {
    ZegoExpressEngine.onRoomUserUpdate = (roomID, updateType, List<ZegoUser> userList) {
      debugPrint('onRoomUserUpdate: roomID: $roomID, userList: ${userList.map((e) => e.userID)}');
    };
    ZegoExpressEngine.onRoomStreamUpdate = (roomID, updateType, List<ZegoStream> streamList, extendedData) {
      debugPrint('onRoomStreamUpdate: roomID: $roomID, updateType: $updateType, streamList: ${streamList.map((e) => e.streamID)}');
      if (updateType == ZegoUpdateType.Add) {
        for (final stream in streamList) {
          startPlayStream(stream.streamID);
        }
      } else {
        for (final stream in streamList) {
          stopPlayStream(stream.streamID);
        }
      }
    };
  }

  void stopListenEvent() {
    ZegoExpressEngine.onRoomUserUpdate = null;
    ZegoExpressEngine.onRoomStreamUpdate = null;
  }

  Future<void> startPublish() async {
    String streamID = '${widget.roomID}_${widget.localUserID}_call';
    return ZegoExpressEngine.instance.startPublishingStream(streamID);
  }

  Future<void> stopPublish() async {
    return ZegoExpressEngine.instance.stopPublishingStream();
  }

  Future<void> startPlayStream(String streamID) async {
    // Start playing the remote audio stream, but do not show the video
    ZegoExpressEngine.instance.startPlayingStream(streamID);
  }

  Future<void> stopPlayStream(String streamID) async {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
  }

  // button rows
  Positioned _buttonRows(BuildContext context) {
    return Positioned(
      bottom: 35,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Volume button (Speaker toggle)
          CustomButton(
            icon: PhosphorIcons.speakerHigh(),
            isActive: speakerHigh,
            onPressed: () async {
              setState(() {
                speakerHigh = !speakerHigh;
              });
              if (speakerHigh) {
                // Turn on the speaker
                ZegoExpressEngine.instance.setAudioRouteToSpeaker(true);
              } else {
                // Turn off the speaker
                ZegoExpressEngine.instance.setAudioRouteToSpeaker(false);
              }
            },
          ),
          // Mic button (Mute/unmute)
          CustomButton(
            isActive: isMuted,
            icon: PhosphorIcons.microphone(),
            onPressed: () {
              setState(() {
                isMuted = !isMuted;
              });
              if (isMuted) {
                // Mute the microphone
                ZegoExpressEngine.instance.muteMicrophone(true);
              } else {
                // Unmute the microphone
                ZegoExpressEngine.instance.muteMicrophone(false);
              }
            },
          ),
          // End call button
          GestureDetector(
            onTap: () async {
              Navigator.pop(context); // End call
            },
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: primaryColor),
              ),
              child: Icon(
                PhosphorIcons.phoneDisconnect(),
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

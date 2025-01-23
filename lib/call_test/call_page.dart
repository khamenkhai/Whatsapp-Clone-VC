import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:vc_testing/call_test/utils/zegocloud_token.dart';
import 'package:vc_testing/call_test/widgets/buttom_rows.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'key_center.dart';

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({
    super.key,
    required this.localUserID,
    required this.localUserName,
    required this.roomID,
  });

  final String localUserID;
  final String localUserName;
  final String roomID;

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  Widget? localView;
  int? localViewID;
  Widget? remoteView;
  int? remoteViewID;

  bool speakerHigh = true;
  bool isMuted = false;
  bool isVideoOff = false;
  bool isFrontCamera = true;

  final primaryColor = Color(0xffE77917);

  bool useFrontCamera = true;

  @override
  void initState() {
    startListenEvent();
    loginRoom();
    super.initState();
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
      // Permission granted
      print("Camera permission granted!");
    } else if (status.isDenied) {
      // Permission denied
      print("Camera permission denied.");
    } else if (status.isPermanentlyDenied) {
      // Open app settings if permission is permanently denied
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('${widget.roomID}'),
      ),
      body: Stack(
        children: [
          localView ?? Container(),

          // remote view
          Positioned(
            top: MediaQuery.of(context).size.height / 8,
            right: MediaQuery.of(context).size.width / 20,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: AspectRatio(
                aspectRatio: 9.0 / 16.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: remoteView ?? Container(color: Colors.transparent),
                ),
              ),
            ),
          ),

          // bottom rows
          _buttonRows(context),

          // top row
          // Audio status icon (e.g., mute/unmute)
          Positioned(
            top: 35,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  size: 40,
                  icon: PhosphorIcons.arrowsInSimple(),
                  isActive: false,
                  onPressed: () async {},
                ),
                // User info and call duration
                Column(
                  children: [
                    Text(
                      "Mg Win",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // SizedBox(height: 4),
                    Text(
                      "00:01",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                CustomButton(
                  size: 40,
                  icon: PhosphorIcons.cameraRotate(),
                  isActive: false,
                  onPressed: () async {
                    useFrontCamera = !useFrontCamera;
                    if (useFrontCamera) {
                      ZegoExpressEngine.instance.useFrontCamera(true);
                    } else {
                      ZegoExpressEngine.instance.useFrontCamera(false);
                    }
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      // bottomNavigationBar: _buttonRows(context),
    );
  }

  // login room
  Future<ZegoRoomLoginResult> loginRoom() async {
    // The value of `userID` is generated locally and must be globally unique.
    final user = ZegoUser(widget.localUserID, widget.localUserName);

    // The value of `roomID` is generated locally and must be globally unique.
    final roomID = widget.roomID;

    // onRoomUserUpdate callback can be received when "isUserStatusNotify" parameter value is "true".
    ZegoRoomConfig roomConfig = ZegoRoomConfig.defaultConfig()
      ..isUserStatusNotify = true;

    if (kIsWeb) {
      // ! ** Warning: ZegoTokenUtils is only for use during testing. When your application goes live,
      // ! ** tokens must be generated by the server side. Please do not generate tokens on the client side!
      roomConfig.token =
          ZegoTokenUtils.generateToken(appID, serverSecret, widget.localUserID);
    }
    // log in to a room
    // Users must log in to the same room to call each other.
    return ZegoExpressEngine.instance
        .loginRoom(roomID, user, config: roomConfig)
        .then((ZegoRoomLoginResult loginRoomResult) {
      debugPrint(
          'loginRoom: errorCode:${loginRoomResult.errorCode}, extendedData:${loginRoomResult.extendedData}');
      if (loginRoomResult.errorCode == 0) {
        startPreview();
        startPublish();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('loginRoom failed: ${loginRoomResult.errorCode}')));
      }
      return loginRoomResult;
    });
  }

  Future<ZegoRoomLogoutResult> logoutRoom() async {
    stopPreview();
    stopPublish();
    return ZegoExpressEngine.instance.logoutRoom(widget.roomID);
  }

  void startListenEvent() {
    // Callback for updates on the status of other users in the room.
    // Users can only receive callbacks when the isUserStatusNotify property of ZegoRoomConfig is set to `true` when logging in to the room (loginRoom).
    ZegoExpressEngine.onRoomUserUpdate =
        (roomID, updateType, List<ZegoUser> userList) {
      debugPrint(
          'onRoomUserUpdate: roomID: $roomID, updateType: ${updateType.name}, userList: ${userList.map((e) => e.userID)}');
    };
    // Callback for updates on the status of the streams in the room.
    ZegoExpressEngine.onRoomStreamUpdate =
        (roomID, updateType, List<ZegoStream> streamList, extendedData) {
      debugPrint(
          'onRoomStreamUpdate: roomID: $roomID, updateType: $updateType, streamList: ${streamList.map((e) => e.streamID)}, extendedData: $extendedData');
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
    // Callback for updates on the current user's room connection status.
    ZegoExpressEngine.onRoomStateUpdate =
        (roomID, state, errorCode, extendedData) {
      debugPrint(
          'onRoomStateUpdate: roomID: $roomID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
    };

    // Callback for updates on the current user's stream publishing changes.
    ZegoExpressEngine.onPublisherStateUpdate =
        (streamID, state, errorCode, extendedData) {
      debugPrint(
          'onPublisherStateUpdate: streamID: $streamID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
    };
  }

  void stopListenEvent() {
    ZegoExpressEngine.onRoomUserUpdate = null;
    ZegoExpressEngine.onRoomStreamUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;
  }

  Future<void> startPreview() async {
    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      localViewID = viewID;
      ZegoCanvas previewCanvas =
          ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      ZegoExpressEngine.instance.startPreview(canvas: previewCanvas);
    }).then((canvasViewWidget) {
      setState(() => localView = canvasViewWidget);
    });
  }

  Future<void> stopPreview() async {
    ZegoExpressEngine.instance.stopPreview();
    if (localViewID != null) {
      await ZegoExpressEngine.instance.destroyCanvasView(localViewID!);
      if (mounted) {
        setState(() {
          localViewID = null;
          localView = null;
        });
      }
    }
  }

  Future<void> startPublish() async {
    // After calling the `loginRoom` method, call this method to publish streams.
    // The StreamID must be unique in the room.
    String streamID = '${widget.roomID}_${widget.localUserID}_call';
    return ZegoExpressEngine.instance.startPublishingStream(streamID);
  }

  Future<void> stopPublish() async {
    return ZegoExpressEngine.instance.stopPublishingStream();
  }

  Future<void> startPlayStream(String streamID) async {
    // Start to play streams. Set the view for rendering the remote streams.
    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      remoteViewID = viewID;
      ZegoCanvas canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
    }).then((canvasViewWidget) {
      setState(() => remoteView = canvasViewWidget);
    });
  }

  Future<void> stopPlayStream(String streamID) async {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
    if (remoteViewID != null) {
      ZegoExpressEngine.instance.destroyCanvasView(remoteViewID!);
      if (mounted) {
        setState(() {
          remoteViewID = null;
          remoteView = null;
        });
      }
    }
  }

  /// button rows
  Positioned _buttonRows(BuildContext context) {
    return Positioned(
      bottom: 35,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Volume button
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
          // Video button
          CustomButton(
            isActive: isVideoOff,
            icon: PhosphorIcons.videoCamera(),
            onPressed: () async {
              setState(() {
                isVideoOff = !isVideoOff;
              });
              if (isVideoOff) {
                await stopPreview();
                await stopPublish();
              } else {
                await startPreview();
                await startPublish();
              }
            },
          ),
          // Call end button
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
            },
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: primaryColor),
              ),
              child: Transform.rotate(
                angle: 2.4,
                child: PhosphorIcon(
                  PhosphorIcons.phone(),
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),

          // Mic button
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
          // More button
          CustomButton(
            isActive: false,
            icon: PhosphorIcons.dotsThreeOutlineVertical(),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    height: 200,
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.settings),
                          title: Text("Settings"),
                          onTap: () {
                            Navigator.pop(context);
                            // Implement settings logic here
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.share),
                          title: Text("Share Screen"),
                          onTap: () {
                            Navigator.pop(context);
                            // Implement screen sharing logic here
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

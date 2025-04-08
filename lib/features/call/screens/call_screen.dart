import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
class CallScreen extends StatefulWidget {

  static const routeName = '/call-screen';
  
  const CallScreen({
    Key? key,
    required this.localUserID,
    required this.localUserName,
    required this.roomId,
  }) : super(key: key);

  final String localUserID;
  final String localUserName;
  final String roomId;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  final roomTextCtrl = TextEditingController();

  @override
  void initState() {
    roomTextCtrl.text = widget.roomId;
    init();
    super.initState();
  }

  Future init() async {
    bool permissionsGranted = await requestPermissions();
    if (permissionsGranted) {
      jumpToCallPage(
        context,
        localUserID: widget.localUserID,
        localUserName: widget.localUserName,
        roomID: widget.roomId,
        isVideoCall: true, // Pass isVideoCall flag
      );
    } else {
      // You can show a SnackBar or alert if permissions are not granted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissions not granted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please test with two or more devices'),
            const Divider(),
            Text('Your userID: ${widget.localUserID}'),
            const SizedBox(height: 20),
            Text('Your userName: ${widget.localUserName}'),
            Text('ROOM ID: ${widget.roomId}'),
            const SizedBox(height: 20),
            TextFormField(
              controller: roomTextCtrl,
              decoration: const InputDecoration(labelText: 'roomID'),
            ),
            const SizedBox(height: 20),
            // Video Call Button
            ElevatedButton(
              child: const Text('Video Call'),
              onPressed: () async {
                bool permissionsGranted = await requestPermissions();
                if (permissionsGranted) {
                  jumpToCallPage(
                    context,
                    localUserID: widget.localUserID,
                    localUserName: widget.localUserName,
                    roomID: roomTextCtrl.text,
                    isVideoCall: true, // Pass isVideoCall flag
                  );
                } else {
                  // You can show a SnackBar or alert if permissions are not granted
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Permissions not granted')),
                  );
                }
              },
            ),
            // Voice Call Button
            ElevatedButton(
              child: const Text('Voice Call'),
              onPressed: () async {
                bool permissionsGranted = await requestPermissions();
                if (permissionsGranted) {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => VoiceCallPage(
                  //       localUserID: widget.localUserID,
                  //       localUserName: widget.localUserName,
                  //       roomID: roomTextCtrl.text,
                  //     ),
                  //   ),
                  // );
                } else {
                  // Handle case when permissions are not granted
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Permissions not granted')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Function to check and request permissions
  Future<bool> requestPermissions() async {
    // Request Camera and Microphone permissions
    PermissionStatus cameraStatus = await Permission.camera.request();
    PermissionStatus micStatus = await Permission.microphone.request();

    // Return true if both permissions are granted
    return cameraStatus.isGranted && micStatus.isGranted;
  }

  // Navigate to CallPage based on whether it's a video call or voice call
  void jumpToCallPage(BuildContext context,
      {required String roomID,
      required String localUserID,
      required String localUserName,
      required bool isVideoCall}) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => isVideoCall
    //         ? VideoCallPage(
    //             localUserID: localUserID,
    //             localUserName: localUserName,
    //             roomID: roomID,
    //           )
    //         : VoiceCallPage(
    //             localUserID: localUserID,
    //             localUserName: localUserName,
    //             roomID: roomID,
    //           ),
    //   ),
    
  }
}

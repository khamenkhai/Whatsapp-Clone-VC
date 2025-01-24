import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_testing/features/call/controller/call_controller.dart';
import 'package:vc_testing/models/call.dart';

class CallPickupScreen extends ConsumerStatefulWidget {
  final Widget scaffold;
  const CallPickupScreen({
    Key? key,
    required this.scaffold,
  }) : super(key: key);

  @override
  ConsumerState<CallPickupScreen> createState() => _CallPickupScreenState();
}

class _CallPickupScreenState extends ConsumerState<CallPickupScreen> {
 
  bool _hasTriggeredIncomingCall = false; // Track if call has been triggered


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: ref.watch(callControllerProvider).callStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.data() != null) {
          Call callData =
              Call.fromMap(snapshot.data!.data() as Map<String, dynamic>);

          // Trigger incoming call only if not dialed yet
          if (!callData.hasDialled && !_hasTriggeredIncomingCall) {
            // _triggerIncomingCall(
            //   callerName: callData.callerName,
            //   roomId: callData.callId,
            //   localUserID: callData.callId,
            // );
          }

          // Display the UI for the incoming call
          // return _oldScaffold(callData, context);
        }

        // Return the default scaffold if there's no incoming call data
        return widget.scaffold;
      },
    );
  }

  // Scaffold _oldScaffold(Call callData, BuildContext context) {
  //   return Scaffold(
  //     body: Container(
  //       alignment: Alignment.center,
  //       padding: const EdgeInsets.symmetric(vertical: 20),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text(
  //             'Incoming Call : ${callData.callId}',
  //             style: TextStyle(
  //               fontSize: 30,
  //               color: Colors.white,
  //             ),
  //           ),
  //           const SizedBox(height: 50),
  //           CircleAvatar(
  //             backgroundImage: NetworkImage(callData.callerPic),
  //             radius: 60,
  //           ),
  //           const SizedBox(height: 50),
  //           Text(
  //             callData.callerName,
  //             style: const TextStyle(
  //               fontSize: 25,
  //               color: Colors.white,
  //               fontWeight: FontWeight.w900,
  //             ),
  //           ),
  //           const SizedBox(height: 75),
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               IconButton(
  //                 onPressed: () {
  //                   Navigator.pop(context); // End the call
  //                 },
  //                 icon: const Icon(Icons.call_end, color: Colors.redAccent),
  //               ),
  //               const SizedBox(width: 25),
  //               IconButton(
  //                 onPressed: () async {
  //                   await requestPermissions().then((value) {
  //                     if (value) {
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (context) => CallScreen(
  //                             localUserID: callData.receiverId,
  //                             localUserName: callData.receiverName,
  //                             roomId: callData.callId,
  //                           ),
  //                         ),
  //                       );
  //                     }
  //                   });
  //                 },
  //                 icon: const Icon(
  //                   Icons.call,
  //                   color: Colors.green,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }


}

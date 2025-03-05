import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_testing/call_test/call_kit_service.dart';
import 'package:vc_testing/common/utils/colors.dart';
import 'package:vc_testing/common/widgets/loader.dart';
import 'package:vc_testing/features/auth/controller/auth_controller.dart';
import 'package:vc_testing/features/call/controller/call_controller.dart';
import 'package:vc_testing/features/call/screens/call_pickup_screen.dart';
import 'package:vc_testing/features/chat/widgets/bottom_chat_field.dart';
import 'package:vc_testing/models/user_model.dart';
import 'package:vc_testing/features/chat/widgets/chat_list.dart';

class MobileChatScreen extends ConsumerWidget {
  static const String routeName = '/mobile-chat-screen';
  final String name;
  final String uid;
  final bool isGroupChat;
  final String profilePic;
  const MobileChatScreen({
    Key? key,
    required this.name,
    required this.uid,
    required this.isGroupChat,
    required this.profilePic,
  }) : super(key: key);

  void makeCall({
    required WidgetRef ref,
    required BuildContext context,
    required String receiverToken,
  }) {
    ref.read(callControllerProvider).makeCall(
          context: context,
          receiverName: name,
          receiverUid: uid,
          receiverProfilePic: profilePic,
          isGroupChat: false,
          receiverDeviceToken: receiverToken,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CallPickupScreen(
      scaffold: Scaffold(
        appBar: AppBar(
          backgroundColor: appBarColor,
          title: isGroupChat
              ? Text(name)
              : StreamBuilder<UserModel>(
                  stream: ref.read(authControllerProvider).userDataById(uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Loader();
                    }
                    return Column(
                      children: [
                        Text(name),
                        Text(
                          snapshot.data!.isOnline ? 'online' : 'offline',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  },
                ),
          centerTitle: false,
          actions: [
            StreamBuilder<UserModel>(
              stream: ref.read(authControllerProvider).userDataById(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }
                return IconButton(
                  onPressed: () => makeCall(
                      ref: ref, context: context, receiverToken: snapshot.data?.deviceToken ?? ""),
                  icon: Icon(Icons.video_call),
                );
              },
            ),
            IconButton(
              onPressed: () {
                _triggerIncomingCall(context);
              },
              icon: const Icon(Icons.notification_add),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ChatList(
                recieverUserId: uid,
                isGroupChat: isGroupChat,
              ),
            ),
            BottomChatField(
              recieverUserId: uid,
              isGroupChat: isGroupChat,
            ),
          ],
        ),
      ),
    );
  }

  void _triggerIncomingCall(BuildContext context) {
    final CallKitService _callKitService = CallKitService();

    _callKitService.showIncomingCall(
      callerName: "Hello world",
      localUserID: "adfd",
      roomId: "dff",
    );
  }
}

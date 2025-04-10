import 'package:flutter/material.dart';
import 'package:vc_testing/common/widgets/error.dart';
import 'package:vc_testing/features/auth/screens/login_screen.dart';
import 'package:vc_testing/features/call/screens/call_screen.dart';
import 'package:vc_testing/features/group/screens/create_group_screen.dart';
import 'package:vc_testing/features/select_contacts/screens/select_contacts_screen.dart';
import 'package:vc_testing/features/chat/screens/mobile_chat_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case LoginScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    // case OTPScreen.routeName:
    //   final verificationId = settings.arguments as String;
    //   return MaterialPageRoute(
    //     builder: (context) => OTPScreen(
    //       verificationId: verificationId,
    //     ),
    //   );
    // case UserInformationScreen.routeName:
    //   return MaterialPageRoute(
    //     builder: (context) => const UserInformationScreen(),
    //   );
    case SelectContactsScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const SelectContactsScreen(),
      );
    case MobileChatScreen.routeName:
      final arguments = settings.arguments as Map<String, dynamic>;
      final name = arguments['name'];
      final uid = arguments['uid'];
      final isGroupChat = arguments['isGroupChat'];
      final profilePic = arguments['profilePic'];
      return MaterialPageRoute(
        builder: (context) => MobileChatScreen(
          name: name,
          uid: uid,
          isGroupChat: isGroupChat,
          profilePic: profilePic,
        ),
      );
    // case ConfirmStatusScreen.routeName:
    //   final file = settings.arguments as File;
    //   return MaterialPageRoute(
    //     builder: (context) => ConfirmStatusScreen(
    //       file: file,
    //     ),
    //   );
    // case StatusScreen.routeName:
    //   final status = settings.arguments as Status;
    //   return MaterialPageRoute(
    //     builder: (context) => StatusScreen(
    //       status: status,
    //     ),
    //   );
    case CreateGroupScreen.routeName:
      return MaterialPageRoute(
        builder: (context) => const CreateGroupScreen(),
      );
    case CallScreen.routeName:
    
      final arguments = settings.arguments as Map<String, dynamic>;
      String localUserID = arguments['localUserID'];
      final localUserName = arguments['localUserName'];
      final roomId = arguments['roomId'];

      return MaterialPageRoute(
        builder: (context) => CallScreen(
          localUserID: localUserID,
          localUserName: localUserName,
          roomId: roomId,
        ),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: ErrorScreen(error: 'This page doesn\'t exist'),
        ),
      );
  }
}

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_http_logger/pretty_http_logger.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:vc_testing/service_json.dart';

final notiServiceProvider = Provider((ref) => NotificationsService());

class NotificationsService {
  final _firebaseMessaging = FirebaseMessaging.instance;

  /// Request Firebase notification permissions
  Future<void> requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  /// Retrieve the Firebase device token
  Future<String> getDeviceToken() async {
    final token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');
    return token ?? '';
  }

  /// Initialize Firebase notifications
  void initializeNotifications(BuildContext context) async {
    // final callKitService = CallKitService();

  
    // Handle notifications when the app is in the background
    FirebaseMessaging.onBackgroundMessage((message) async {
      return await _backgroundMessageHandler(message);
    });

    // Handle notifications when the app is opened via a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print("the navigation is tap :: ${message.data}");
      _navigateOnNotificationTap(context);
    });

    // When the app is open
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("onmessagelisten: ${message.data}");
      if (message.notification != null) {
        if (message.data.isNotEmpty || message.data != {}) {
          // callKitService.showIncomingCall(
          //   roomId: message.data['roomId'] ?? '',
          //   callerName: message.data["callerName"] ?? "",
          //   localUserID: message.data['localUserID'] ?? 'Unknown',
          // );
        } else {}
      }
    });

    // Handle the initial notification when the app launches
    _handleInitialMessage(context);
  }

  /// Handle the initial notification when the app launches
  Future<void> _handleInitialMessage(BuildContext context) async {
    print("_handleInitialMessage");
    final message = await _firebaseMessaging.getInitialMessage();
    if (message != null) {
      _navigateOnNotificationTap(context);
    }
  }

  /// Navigate to a specific screen on notification tap
  void _navigateOnNotificationTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Hello World')),
        ),
      ),
    );
  }

  /// Get Firebase server access token
  static Future<String> getAccessToken() async {
    final serviceAccountJson = firebaseJson;

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    try {
      var client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
      );

      // Get access token
      auth.AccessCredentials credentials =
          await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client,
      );

      client.close();

      return credentials.accessToken.data;
    } catch (e) {
      print('**Error obtaining access token: $e');
      rethrow;
    }
  }

  /// Send a notification to a specific device
  Future<void> sendNotification({
    required String title,
    required String body,
    required String callerName,
    required String callerPhone,
    required String deviceToken,
    required String roomId,
  }) async {
    print("making call ; ${callerName}, ${callerPhone}");
    final serverAccessToken = await getAccessToken();
    // final deviceToken = await getDeviceToken();
    final endpoint =
        'https://fcm.googleapis.com/v1/projects/$firebaseProjectName/messages:send';

    final message = {
      "message": {
        "token": deviceToken,
        "notification": {
          "title": title,
          "body": body,
        },
        "data": {
          "callerName": "${callerName}",
          "callerPhone": "${callerPhone}",
          "roomId": "${roomId}",
        },
      },
    };
    final _http = HttpWithMiddleware.build(
      middlewares: [HttpLogger(logLevel: LogLevel.BODY)],
    );

    final response = await _http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessToken',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('Notification sent successfully');
    } else {
      debugPrint('Failed to send notification: ${response.body}');
    }
  }

  /// Background message  (unchanged) to show when i app is close
  static Future<void> _backgroundMessageHandler(
    RemoteMessage message,
    // BuildContext context,
  ) async {
    print("background message handler : ${message.data}");

    // final callKitService = CallKitService();

    // callKitService.showIncomingCall(
    //   roomId: "abc",
    //   callerName: "ddd",
    //   localUserID: "bbb",
    // );

    // if (message.data != {}) {
    //   callKitService.showIncomingCall(
    //     roomId: "roomId",
    //     callerName: "CallerName",
    //     localUserID: 'Unknown',
    //   );
    // } else {
    //   // will remove
    //   callKitService.showIncomingCall(
    //     roomId: message.data['roomId'] ?? '',
    //     callerName: message.data["callerName"],
    //     localUserID: message.data['localUserID'] ?? 'Unknown',
    //   );
    // }
  }
}

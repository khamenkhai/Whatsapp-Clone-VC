import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pretty_http_logger/pretty_http_logger.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:vc_testing/call_test/call_kit_service.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'Hign Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
  playSound: true,
);

///notification service
class NotificationsService {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  ///init local notification
  void _initLocalNotification(BuildContext context) {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) async {
       
        debugPrint(
          "abcdefg" +
              Map<String, dynamic>.from(json.decode(response.payload ?? ""))
                  .toString(),
        );
      },
    );
  }

  ///show local notification
  Future<void> _showLocalNotification({
    required RemoteMessage message,
    required BuildContext context,
  }) async {

    print("showing local noti");
    final styleInformation = BigTextStyleInformation(
      message.notification!.body.toString(),
      htmlFormatBigText: true,
      contentTitle: message.notification!.title,
      htmlFormatTitle: true,
    );

    final androidDetails = AndroidNotificationDetails(
      'com.example.chat_app.urgent',
      'mychannelid',
      importance: Importance.max,
      styleInformation: styleInformation,
      priority: Priority.max,
      sound: RawResourceAndroidNotificationSound(""),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title,
      message.notification!.body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  ///request firebase permission
  Future<void> requestPermission() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
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

  ///get firebase device token
  Future<String> getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    return token.toString();
  }

  ///initialize firebase notification
  void initFirebaseNotification(context) {
    ///call this function to init local notification
    _initLocalNotification(context);

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) async {
        CallKitService callKitService = CallKitService();
      callKitService.showIncomingCall(roomId: "roomId", callerName: "John", localUserID: "localUserID", context: context);
        print("on message opened app${message.notification!.title}\n");
        // await Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (_) => NotificationDetailWidget(
        //       data: message.data.isNotEmpty ? message.data : {},
        //     ),
        //   ),
        // );
      },
    );

    handleInitialMessage(context);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("on message${message.data}\n");

      CallKitService callKitService = CallKitService();
      callKitService.showIncomingCall(roomId: "roomId", callerName: "Kham", localUserID: "localUserID", context: context);
      ///show local notification
      //await _showLocalNotification(message: message, context: context);
    });
  }

  Future<void> handleInitialMessage(BuildContext context) async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    final RemoteMessage? message = await _firebaseMessaging.getInitialMessage();
    if (message != null) {
      // await Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (_) => NotificationDetailWidget(
      //       data: message.data.isNotEmpty ? message.data : {},
      //     ),
      //   ),
      // );
    }
  }

  ////http moddleware
  HttpWithMiddleware http = HttpWithMiddleware.build(
    middlewares: [
      HttpLogger(
        logLevel: LogLevel.BODY,
      ),
    ],
  );

  ///get firebase access token
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "khaiproject-8d74f",
      "private_key_id": "d930eaf13776a738c0dff75a1c28442860328d8a",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCTHIk0UV8X2agd\n1/SDu2uCiX6efAqo6/D71I1p+rxJ/WT+7iU5irMZzsr/y7kRr6MN1WgplGATv85Q\n1/bBp40OU0Icl3ALbMgkv1upCQXlxU2Ie6xaP53tH46MeRoqS3HATDRh4hAvPrGu\n5nUmairOmLZzHGAB5gorbJusQh+3EEVEqisaWa6/zNc9USAlM+BFpOEUZpGkOXN9\nbp91ES8PhUyXG2hyxzP2w+xXhL8Gl1scj/I6FQd/C+Zc8C2dEGSd+CurYpTiF9KT\nlbI8ZbC6eW11JcKRh2Zi1128wHq5ZLaQ1vSFiOYjsKbcamAMRt9szlUjui6JY5Bp\nm8OAGJFtAgMBAAECggEAG6uCoBFNFFCXZzObFVr/bABeDUOyApdMTqWqSpyDZVxQ\nroWPAV119fz4IDhKkUnKnru82ZNDpftN/FU+n6qa5K6i0Ptn8vItTAIlJKxijFb5\n0BnI73mnQ/ZLSt8tXXauyNdcg+uwFR7S711/++98qTq+mHSmFz1UPNozBqmySu1u\nwxgm3LWenmvBP9zdNiKB9qjOBYJzsAZzVxpppmnyJGo9q+EjQGcpwsqN4+6UhRND\nHGEGYhb5C00UDFtl2171uIHr4FDgvOk79JWATKb3lk+c+iYLP/g/KPLlWxw2DavE\nw6A1QRL3jMl8NclSXEWivwrlHvwcgyUL0h3N0ec+kQKBgQDE7sM4x5whWrKF3353\nVTnvOqABzAlMoqBRTnEQZTO7UumZyAN0KAhHJ9y63RhvyiVmLuOmVh5FSU+4hjPW\npqLkWQ0/5kim4gNa9+9/W+GY1lnjlYs3wuLfv2UT2gK8ACdhx6rOqUlBohgQxlP/\nte23UdoHzQUz1xe4sFneg5e53QKBgQC/PFAQXJBixfYhq7MvKNuvnEjWHhY1UmHY\n3eRYu1Ex/8DIaQNhiQEefwioKVnqV7vBsPNCiZHVo0HGykVbNZDXQDSiNzceJlW7\nobQ1hZAY7HkQEIrr9XkyQoWSByKsX1mDtoSwWvAv/PjMbhnSG1Ymb1oU94XqCmBs\noC7OEeXk0QKBgQCaDj3h+SUGYrEtUPzZ1W4Q20e4oCjWLpJDiJ2iOckSTXY4uuMY\nxwhSwbhG5hbrvLMtEJk90jiz8vnOXA3JaWocQB3BUyCajEwbqcFNXE9LBMQk6SOT\nZ32bk1o7AV0KPQSR1WSlboDEO02gMcYcT/G6aumpGJVtTGJeNHbZPxA+cQKBgBpQ\neEvoEM4mo1m6wKtKmgAuJy+fcDriHSi0T8mN7PxOTv7ExHxVV9wUauKI3iCK9gEP\nEkojl/enwVNTXfvRAR89bICtzF3PtJhfBecfe9aSI458WEFjw8uQr8SKStEhRbYE\nFXoW6VoRG0M2G0N4E4CybdjYvoqX5vDLkeU1PUchAoGAIeUPTBtX94ACA2OUMu5V\ncNEYmjt0S/UhKx+V+VeRqzn7+CetMffFjzpNT0uE2PeSfUjbI+9vl7yJ+IKFeJKk\nUhHOQeKxTaVtI6QqbkUZU0gtsvme8IWtNWwqbG3UmRYqZ6Vr76BTgRVgHzsmHkIf\nhtYhFQsk+kPhUfAzVY//Gj8=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-5kwnt@khaiproject-8d74f.iam.gserviceaccount.com",
      "client_id": "108602295006153287649",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-5kwnt%40khaiproject-8d74f.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

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

  //get server access token key
  Future<String> getServerAccessTokenKey() async {
    final String serverAccessTokenKey = await getAccessToken();
    return serverAccessTokenKey;
  }

  ///to send notification
  sendNotification({
    required String deviceToken,
    required BuildContext context,
    required String title,
    required String body,
  }) async {
    final String serverAccessTokenKey = await getAccessToken();

    print("server access token key : ${serverAccessTokenKey}");

    String endpointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/khaiproject-8d74f/messages:send';

    final Map<String, dynamic> message = {
      "message": {
        "token": "${deviceToken}",
        "notification": {"title": "${title} ", "body": "${body} "},
        "data": {"story_id": "story_12345"}
      }
    };

    // print("request body : ${jsonEncode(message)}");

    // print("token : -> Bearer ${serverAccessTokenKey}");

    var response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${serverAccessTokenKey}',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ///the notification is working
    } else {
      print('The notification is not working anymore!!');
    }
  }
}

Future<String> getFcmToken() async {
  try {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print("FCM Token: $token");
    } else {
      print("Failed to get FCM token");
    }
    return token ?? "";
  } catch (e) {
    print("Error getting FCM token: $e");
    return "";
  }
}

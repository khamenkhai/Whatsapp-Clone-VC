import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_testing/call_test/key_center.dart';
import 'package:vc_testing/common/utils/colors.dart';
import 'package:vc_testing/common/widgets/error.dart';
import 'package:vc_testing/common/widgets/loader.dart';
import 'package:vc_testing/features/auth/controller/auth_controller.dart';
import 'package:vc_testing/features/landing/screens/landing_screen.dart';
import 'package:vc_testing/firebase_options.dart';
import 'package:vc_testing/router.dart';
import 'package:vc_testing/mobile_layout_screen.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await createEngine();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}


Future<void> createEngine() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Get your AppID and AppSign from ZEGOCLOUD Console
  //[My Projects -> AppID] : https://console.zegocloud.com/project
  await ZegoExpressEngine.createEngineWithProfile(ZegoEngineProfile(
    appID,
    ZegoScenario.Default,
    appSign: appSign,
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Whatsapp UI',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          color: appBarColor,
        ),
      ),
      onGenerateRoute: (settings) => generateRoute(settings),
      home: ref.watch(userDataAuthProvider).when(
            data: (user) {
              if (user == null) {
                return const LandingScreen();
              }
              return const MobileLayoutScreen();
            },
            error: (err, trace) {
              return ErrorScreen(
                error: err.toString(),
              );
            },
            loading: () => const Loader(),
          ),
    );
  }
}

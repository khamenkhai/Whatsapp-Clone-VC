import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/route_manager.dart';
import 'package:vc_testing/common/utils/colors.dart';
import 'package:vc_testing/common/widgets/error.dart';
import 'package:vc_testing/common/widgets/loader.dart';
import 'package:vc_testing/features/auth/controller/auth_controller.dart';
import 'package:vc_testing/features/landing/screens/landing_screen.dart';
import 'package:vc_testing/firebase_options.dart';
import 'package:vc_testing/router.dart';
import 'package:vc_testing/mobile_layout_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}



class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetMaterialApp(
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

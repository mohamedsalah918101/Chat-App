import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:push_notification/api/firebase_api.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:push_notification/consts.dart';
import 'package:push_notification/services/auth_service.dart';
import 'package:push_notification/services/navigation_service.dart';
import 'package:push_notification/utils.dart';
import 'package:push_notification/zegocloud/views/auth/login.dart';
import 'package:push_notification/zegocloud/views/home/home.dart';
import 'package:push_notification/zegocloud/zim/zim_login.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await ZIMKit().init(appID: appId, appSign: appSign);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await registerServices();
  await FirebaseApi().initNotification();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late AuthService _authService;

  MyApp({super.key}) {
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        fontFamily: GoogleFonts.ibmPlexSans().fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        // textTheme: GoogleFonts.montserratTextTheme(),
      ),
      home: ZimLogin(),
      // FirebaseAuth.instance.currentUser == null ? LoginPage() : HomePage(),
      // navigatorKey: _navigationService.navigatorKey,
      // initialRoute: _authService.user != null ? "/home" : "/login",
      // routes: _navigationService.routes,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:textextractorpro/screens/extracttextdisplay.dart';

import 'screens/splashscreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class AppStateHandler extends WidgetsBindingObserver {
  static bool isAppInForeground = false;

  static void initialize() {
    final instance = AppStateHandler();
    instance._init();
  }

  void _init() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    isAppInForeground = state == AppLifecycleState.resumed;
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppStateHandler.initialize();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Text Extractor",
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/result': (context) => ResultScreen(),
      },
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user/infoHandler/app_info.dart';
import 'package:user/screens/login_screen.dart';
import 'package:user/screens/main_screen.dart';
import 'package:user/screens/rate_helper_screen.dart';
import 'package:user/screens/register_screen.dart';
import 'package:user/screens/search_places_screen.dart';
import 'package:user/screens/trips_history_screen.dart';
import 'package:user/splashScreen/splash_screen.dart';
import 'package:user/themeProvider/theme_provider.dart';
import 'package:user/widgets/pay_fare_amount_dialog.dart';


Future<void> main() async{
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'Flutter Demo',
        themeMode: ThemeMode.system,
        theme:MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );

  }
}


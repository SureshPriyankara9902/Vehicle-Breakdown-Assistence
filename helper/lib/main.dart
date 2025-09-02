import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:helper/screens/RideRequestScreen.dart';
import 'package:helper/screens/vehicle_info_screen.dart';
import 'package:helper/splashScreen/splash_screen.dart';
import 'package:helper/themeProvider/theme_provider.dart';
import 'package:helper/widgets/fare_amount_collection_dialog.dart';
import 'package:provider/provider.dart';


import 'infoHandler/app_info.dart';


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



import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';

class MyThemes {
  static final darkTheme = ThemeData (
    scaffoldBackgroundColor : Colors.grey.shade900,
    colorScheme: ColorScheme.dark(),
  );

  static final lightTheme = ThemeData (
    scaffoldBackgroundColor : Colors.white,
    colorScheme: ColorScheme.light(),
  );
}
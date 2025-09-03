import 'package:flutter/material.dart';

class AppColors {
  static Color mainColor = const Color(0xff312744);
  static Color bgColor = Colors.grey[900]!;
  static Color whiteColor = Colors.white;
  static Color blackColor = Colors.black;

  static MaterialColor primaryColorDark = const MaterialColor(0xff624E88,
    <int, Color>{
      50: Color(0xff58467A),
      100: Color(0xff4E3E6D),
      200: Color(0xff45375F),
      300: Color(0xff3B2F52),
      400: Color(0xff312744),
      500: Color(0xff271F36),
      600: Color(0xff1D1729),
      700: Color(0xff14101B),
      800: Color(0xff0A080E),
      900: Color(0xff000000),
    },
  );

  static MaterialColor primaryColorLight = const MaterialColor(0xff624E88,
    <int, Color>{
      50: Color(0xff726094),
      100: Color(0xff8171A0),
      200: Color(0xff9183AC),
      300: Color(0xffA195B8),
      400: Color(0xffB1A7C4),
      500: Color(0xffC0B8CF),
      600: Color(0xffD0CADB),
      700: Color(0xffE0DCE7),
      800: Color(0xffEFEDF3),
      900: Color(0xffFFFFFF),
    },
  );
}
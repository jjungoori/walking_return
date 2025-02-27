import 'package:flutter/material.dart';

class DefaultDatas{
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(16));
  static const EdgeInsets buttonPadding = EdgeInsets.all(12);
  static const EdgeInsets modalPadding = EdgeInsets.all(20);
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(vertical: 20, horizontal: 18);
  static const EdgeInsets noRoundPadding = EdgeInsets.symmetric(horizontal: 8);

  // static AppBar appBar = ;
}

class ColorDatas{
  static const Color primary = Color(0xFFFFDE48);
  static const Color secondary = Color(0xffebb700);
  static const Color onPrimaryTitle = Color.fromARGB(255, 255, 255, 255);
  static const Color onPrimaryContent = Color.fromARGB(255, 255, 255, 255);
  static const Color onPrimaryDescription = Color.fromARGB(240,240,240,255);

  static const Color background = Color(0xFFf9f9f9);
  static const Color backgroundSoft = Color(0xFFf0f0f0);

  static const Color onBackground = Color(0xFF111111);
  static const Color onBackgroundSoft = Color(0xFF767676);
  static Color splashColor = Colors.white.withOpacity(0.5);
  static Color shadow = Colors.black.withOpacity(0.1);
  static const Color error = Color(0xFFdd0000);
  static const Color onError = Color(0xFF660000);

  static const Color button = secondary;
}

class TextDatas{
  static const TextStyle title = TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 24,
      fontWeight: FontWeight.w300,
      color: ColorDatas.onBackground
    // fontWeight: FontWeight.w600
  );

  static const TextStyle splashTitle = TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 24,
      fontWeight: FontWeight.w300,
      color: ColorDatas.secondary
    // fontWeight: FontWeight.w600
  );

  static const TextStyle subtitle = TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 20,
      fontWeight: FontWeight.w200,
      color: ColorDatas.onBackground
    // fontWeight: FontWeight.w600
  );

  static const TextStyle description = TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 16,
      color: ColorDatas.onBackgroundSoft
  );

  static const TextStyle bottomButton = TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 20,
      fontWeight: FontWeight.w300,
      color: ColorDatas.onPrimaryTitle
  );

  static const TextStyle homeButton = TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 18,
      fontWeight: FontWeight.w300,
      color: ColorDatas.onBackgroundSoft
  );

  static const TextStyle importantText = TextStyle(
      fontFamily: 'Pretendard',
      fontSize: 20,
      fontWeight: FontWeight.w400,
      color: ColorDatas.onBackground
    // fontWeight: FontWeight.w600
  );
}

class InputFieldDatas{
  static const InputDecoration inputDecoration = InputDecoration(
    filled: true,
    fillColor: ColorDatas.button,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide.none,
    ),
  );
}
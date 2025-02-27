import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import 'datas.dart';

void myShowModalBottomSheet(BuildContext context, Widget child) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final mediaQuery = MediaQuery.of(context);
        final keyboardHeight = mediaQuery.viewInsets.bottom;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: EdgeInsets.only(bottom: keyboardHeight),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              padding: DefaultDatas.modalPadding,
              decoration: BoxDecoration(
                color: ColorDatas.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: SingleChildScrollView(
                child: child,
              ),
            ),
          ),
        );
      }
  );
}

String getDayOfWeek() {
  switch (DateTime.now().weekday) {
    case 1: return '월요일';
    case 2: return '화요일';
    case 3: return '수요일';
    case 4: return '목요일';
    case 5: return '금요일';
    case 6: return '토요일';
    case 7: return '일요일';
    default: return '';
  }
}
//
// String convertHash(String str) {
//   final bytes = utf8.encode(str);
//   final hash = sha256.convert(bytes);
//   return hash.toString();
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:walking/datas.dart';

class MyTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final bool isPassword;
  final String? title;
  final int? maxLength;

  const MyTextField({
    Key? key,
    required this.title,
    this.hintText = '',
    this.controller,
    this.prefixIcon,
    this.maxLength,
    this.isPassword = false,
  }) : super(key: key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();


  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: TextField(
        decoration: InputDecoration(
          labelText: widget.title,
          labelStyle: TextStyle(color: Colors.grey), // 기본 라벨 색상
          counterText: '${widget.controller!.text.length}/20',
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: ColorDatas.backgroundSoft,
        ),
        cursorColor: Colors.grey, // 커서 색상
        controller: widget.controller!,
        inputFormatters: [
          LengthLimitingTextInputFormatter(20),
        ],
        onChanged: (text) {
          // Force the widget to rebuild to show the character count
          (context as Element).markNeedsBuild();
        },
      ),
    );
  }
}


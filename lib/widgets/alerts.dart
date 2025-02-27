import 'package:flutter/material.dart';

import '../datas.dart';
import 'buttons.dart';

class MyAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Color confirmColor;

  MyAlertDialog({
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCancel,
    this.confirmColor = ColorDatas.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorDatas.background,
      shape: RoundedRectangleBorder(borderRadius: DefaultDatas.borderRadius),
      child: Padding(
        padding: DefaultDatas.modalPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: DefaultDatas.noRoundPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextDatas.subtitle,
                  ),
                  SizedBox(height: 16),
                  Text(
                    content,
                    style: TextDatas.description,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: MyAnimatedButton(
                    onPressed: onCancel,
                    color: ColorDatas.backgroundSoft,
                    child: Center(
                      child: Text(
                        "취소",
                        style: TextStyle(
                          color: ColorDatas.onBackgroundSoft,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: MyAnimatedButton(
                    onPressed: onConfirm,
                    color: confirmColor,
                    child: Center(
                      child: Text(
                        "확인",
                        style: TextStyle(
                          color: ColorDatas.onPrimaryTitle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MyChildAlertDialog extends StatefulWidget {
  final String title;
  final Widget child;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Color confirmColor;

  MyChildAlertDialog({
    required this.title,
    required this.child,
    required this.onConfirm,
    required this.onCancel,
    this.confirmColor = ColorDatas.secondary,
  });

  @override
  _MyChildAlertDialogState createState() => _MyChildAlertDialogState();
}

class _MyChildAlertDialogState extends State<MyChildAlertDialog> {
  bool _isToggled = false; // 토글 상태 관리

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorDatas.background,
      shape: RoundedRectangleBorder(borderRadius: DefaultDatas.borderRadius),
      child: Padding(
        padding: DefaultDatas.modalPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: DefaultDatas.noRoundPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextDatas.subtitle,
                  ),
                  SizedBox(height: 16),
                  widget.child
                ],
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: MyAnimatedButton(
                    onPressed: widget.onCancel,
                    color: ColorDatas.backgroundSoft,
                    child: Center(
                      child: Text(
                        "취소",
                        style: TextStyle(
                          color: ColorDatas.onBackgroundSoft,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: MyAnimatedButton(
                    onPressed: widget.onConfirm,
                    color: widget.confirmColor,
                    child: Center(
                      child: Text(
                        "확인",
                        style: TextStyle(
                          color: ColorDatas.onPrimaryTitle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class MyChildTipDialog extends StatefulWidget {
  final String title;
  final Widget child;
  final Color confirmColor;

  MyChildTipDialog({
    required this.title,
    required this.child,
    this.confirmColor = ColorDatas.secondary,
  });

  @override
  _MyChildTipDialogState createState() => _MyChildTipDialogState();
}

class _MyChildTipDialogState extends State<MyChildTipDialog> {
  bool _isToggled = false; // 토글 상태 관리

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ColorDatas.background,
      shape: RoundedRectangleBorder(borderRadius: DefaultDatas.borderRadius),
      child: Padding(
        padding: DefaultDatas.modalPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: DefaultDatas.noRoundPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextDatas.subtitle,
                  ),
                  SizedBox(height: 16),
                  widget.child
                ],
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: MyAnimatedButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    color: widget.confirmColor,
                    child: Center(
                      child: Text(
                        "확인",
                        style: TextStyle(
                          color: ColorDatas.onPrimaryTitle,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

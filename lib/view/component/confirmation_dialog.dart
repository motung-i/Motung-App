import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/view/designSystem/colors.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.confirmText = '확인',
    this.cancelText = '취소',
  });

  final String title;
  final String content;
  final VoidCallback onConfirm;
  final String confirmText;
  final String cancelText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: Alignment.center,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      title: Text(
        title,
        style: GlobalFontDesignSystem.m2Semi,
        textAlign: TextAlign.center,
      ),
      content: Text(
        content,
        style: GlobalFontDesignSystem.labelRegular.copyWith(
          color: DiaryMainGrey.grey800,
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: ButtonComponent(
                isEnable: false,
                text: cancelText,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: ButtonComponent(
                isEnable: true,
                text: confirmText,
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
              ),
            ),
          ],
        )
      ],
    );
  }

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
    String confirmText = '확인',
    String cancelText = '취소',
  }) {
    return showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        content: content,
        onConfirm: onConfirm,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
  }
}

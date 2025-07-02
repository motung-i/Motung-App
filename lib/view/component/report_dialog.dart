import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:motunge/view/component/button.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/model/review/enum/report_reason.dart';
import 'package:motunge/view/designSystem/colors.dart';

class ReportDialog extends StatefulWidget {
  const ReportDialog({
    super.key,
    required this.onConfirm,
  });

  final ValueChanged<List<ReportReason>> onConfirm;

  @override
  State<ReportDialog> createState() => _ReportDialogState();

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<List<ReportReason>> onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => ReportDialog(onConfirm: onConfirm),
    );
  }
}

class _ReportDialogState extends State<ReportDialog> {
  final List<ReportReason> _selectedReasons = [];

  final Map<ReportReason, String> _reasonLabels = {
    ReportReason.PERSONAL_INFORMATION: "개인정보노출",
    ReportReason.PROMOTION: "홍보성/상업적",
    ReportReason.ABUSE: "욕설/비방",
    ReportReason.SENSATIONALISM: "선정적/불쾌",
    ReportReason.ETC: "기타",
  };

  void _toggleReason(ReportReason reason) {
    setState(() {
      if (_selectedReasons.contains(reason)) {
        _selectedReasons.removeAt(_selectedReasons.indexOf(reason));
      } else {
        _selectedReasons.add(reason);
      }
    });
  }

  Widget _buildReasonItem(ReportReason reason) {
    final bool isSelected =
        _selectedReasons.any((element) => element == reason);
    return GestureDetector(
      onTap: () => _toggleReason(reason),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SvgPicture.asset(
            isSelected
                ? "assets/images/checked.svg"
                : "assets/images/unchecked.svg",
            width: 24.w,
            height: 24.h,
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              _reasonLabels[reason] ?? reason.name,
              style: GlobalFontDesignSystem.m3Regular,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.center,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "신고사유",
                  style: GlobalFontDesignSystem.m2Semi.copyWith(
                    color: DiaryColor.black,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: 24.sp,
                    color: DiaryColor.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reasonLabels.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 24.w,
                mainAxisSpacing: 24.h,
                childAspectRatio: 5,
              ),
              itemBuilder: (context, index) {
                final reason = _reasonLabels.keys.elementAt(index);
                return Align(
                  alignment: Alignment.centerLeft,
                  child: _buildReasonItem(reason),
                );
              },
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ButtonComponent(
                isEnable: _selectedReasons.isNotEmpty,
                enableColor: DiaryColor.systemErrorColor,
                text: "신고하기",
                onPressed: _selectedReasons.isNotEmpty
                    ? () {
                        Navigator.pop(context);
                        widget.onConfirm(_selectedReasons.toList());
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

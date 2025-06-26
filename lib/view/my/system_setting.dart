import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:motunge/routes/navigation_helper.dart';
import 'package:motunge/utils/error_handler.dart';
import 'package:motunge/view/component/confirmation_dialog.dart';
import 'package:motunge/view/component/menu_list_item.dart';
import 'package:motunge/view/component/topBar.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/viewModel/auth_viewmodel.dart';

class SystemSettingPage extends StatelessWidget {
  const SystemSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Column(
      children: [
        Topbar(
          isSelectable: false,
          isPopAble: true,
          selectAbleText: null,
          text: "시스템 설정",
        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: _buildSystemConfig(context)),
      ],
    )));
  }
}

void _showDeleteAccountDialog(BuildContext context) {
  ConfirmationDialog.show(
    context,
    title: "정말 회원탈퇴 하시겠습니까?",
    content: "탈퇴 시 모든 데이터가 삭제되며\n복구할 수 없습니다.",
    confirmText: "탈퇴",
    onConfirm: () async {
      try {
        await AuthViewModel().deleteAccount();
        Navigation.toLogin();
      } catch (e) {
        if (context.mounted) {
          ErrorHandler.showErrorSnackBar(
            context,
            '회원탈퇴 중 오류가 발생했습니다.',
          );
        }
      }
    },
  );
}

Widget _buildSystemConfig(BuildContext context) {
  return Column(
    children: [
      SizedBox(height: 36.h),
      MenuListItem(
        title: "이용약관",
        onTap: () {
          // TODO: 이용약관 페이지로 이동
        },
      ),
      SizedBox(height: 24.h),
      MenuListItem(
        title: "개인정보 처리방침",
        onTap: () {
          // TODO: 개인정보 처리방침 페이지로 이동
        },
      ),
      SizedBox(height: 24.h),
      MenuListItem(
        title: "닉네임 변경",
        onTap: () => context.push('/my/change-nickname'),
      ),
      SizedBox(
        height: 24.h,
      ),
      GestureDetector(
        onTap: () => AuthViewModel().logout(),
        child: Row(
          children: [
            SvgPicture.asset(
              "assets/images/logout.svg",
              width: 24.w,
              height: 24.h,
            ),
            Text(
              "로그아웃",
              style: GlobalFontDesignSystem.m3Regular
                  .copyWith(color: DiaryColor.systemErrorColor),
            ),
          ],
        ),
      ),
      SizedBox(
        height: 24.h,
      ),
      GestureDetector(
        onTap: () => _showDeleteAccountDialog(context),
        child: Row(
          children: [
            SvgPicture.asset(
              "assets/images/delete-profile.svg",
              width: 24.w,
              height: 24.h,
            ),
            Text(
              "회원탈퇴",
              style: GlobalFontDesignSystem.m3Regular
                  .copyWith(color: DiaryColor.systemErrorColor),
            ),
          ],
        ),
      )
    ],
  );
}

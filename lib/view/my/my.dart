import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:motunge/constants/app_constants.dart';
import 'package:motunge/model/auth/profile_response.dart';
import 'package:motunge/view/component/menu_list_item.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';
import 'package:motunge/viewModel/auth_viewmodel.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  ProfileResponse? profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final authViewModel = AuthViewModel();
    final profileData = await authViewModel.getProfile();
    if (mounted) {
      setState(() {
        profile = profileData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 60.h),
                    Text(
                      profile?.nickname ?? AppConstants.loadingText,
                      style: GlobalFontDesignSystem.m1Semi,
                    ),
                    SizedBox(
                      height: 60.h,
                    ),
                    MenuListItem(
                      title: "내가 쓴 리뷰",
                      onTap: () => context.push('/my/reviews'),
                    ),
                    SizedBox(
                      height: 24.h,
                    ),
                    Divider(
                      color: DiaryMainGrey.grey100,
                      height: 1.h,
                    ),
                    SizedBox(
                      height: 24.h,
                    ),
                    MenuListItem(
                      title: "시스템",
                      onTap: () => context.push("/my/system-setting"),
                    )
                  ],
                ))));
  }
}

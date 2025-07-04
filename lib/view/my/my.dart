import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:motunge/bloc/auth/auth_bloc.dart';
import 'package:motunge/bloc/auth/auth_state.dart';
import 'package:motunge/constants/app_constants.dart';
import 'package:motunge/view/component/menu_list_item.dart';
import 'package:motunge/view/designSystem/colors.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthBlocState>(
          key: const ValueKey('my_page_bloc_builder'),
          builder: (context, state) {
            return _buildContent(state);
          },
        ),
      ),
    );
  }

  Widget _buildContent(AuthBlocState state) {
    String nickname = AppConstants.loadingText;

    if (state is AuthAuthenticated && state.profile != null) {
      nickname = state.profile!.nickname;
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(height: 60.h),
          Text(
            nickname,
            style: GlobalFontDesignSystem.m1Semi,
          ),
          SizedBox(height: 60.h),
          MenuListItem(
            title: "내가 쓴 리뷰",
            onTap: () => context.push('/my/reviews'),
          ),
          SizedBox(height: 24.h),
          Divider(
            color: AppColors.grey100,
            height: 1.h,
          ),
          SizedBox(height: 24.h),
          MenuListItem(
            title: "시스템",
            onTap: () => context.push("/my/system-setting"),
          )
        ],
      ),
    );
  }
}

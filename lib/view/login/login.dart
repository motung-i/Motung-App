import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motunge/bloc/auth/auth_bloc.dart';
import 'package:motunge/bloc/auth/auth_event.dart';
import 'package:motunge/bloc/auth/auth_state.dart';
import 'package:motunge/constants/app_constants.dart';
import 'package:motunge/utils/error_handler.dart';
import 'package:motunge/view/designSystem/fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _handleGoogleLogin() {
    context.read<AuthBloc>().add(const AuthGoogleLoginRequested());
  }

  void _handleAppleLogin() {
    context.read<AuthBloc>().add(const AuthAppleLoginRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthBlocState>(
          listener: (context, state) {
            if (state is AuthError) {
              ErrorHandler.showErrorSnackBar(
                context,
                AppConstants.loginErrorMessage,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 153.h,
                    width: double.infinity,
                  ),
                  Image.asset(
                    "assets/images/logo_filled.png",
                    width: 181.w,
                    height: 54.h,
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text("대한민국 못 가본곳이 없을 때까지",
                      style: GlobalFontDesignSystem.m3Semi
                          .copyWith(color: Color(0xff125CED))),
                  SizedBox(
                    height: 307.h,
                  ),
                  GestureDetector(
                    onTap: isLoading ? null : _handleGoogleLogin,
                    child: Container(
                      height: 52.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xffebebeb)),
                        color: isLoading ? Colors.grey[200] : Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 88.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/google.png",
                            width: 24.w,
                            height: 24.h,
                          ),
                          Text(
                            isLoading
                                ? AppConstants.loginLoadingText
                                : AppConstants.loginButtonText,
                            style: GlobalFontDesignSystem.m3Semi.copyWith(
                              color: isLoading ? Colors.grey : Colors.black,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  GestureDetector(
                    onTap: isLoading ? null : _handleAppleLogin,
                    child: Container(
                      height: 52.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xffebebeb)),
                        color: isLoading ? Colors.grey[200] : Colors.white,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 88.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/images/apple.png",
                            width: 24.w,
                            height: 24.h,
                          ),
                          Text(
                            isLoading
                                ? AppConstants.loginLoadingText
                                : AppConstants.appleLoginText,
                            style: GlobalFontDesignSystem.m3Semi.copyWith(
                              color: isLoading ? Colors.grey : Colors.black,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

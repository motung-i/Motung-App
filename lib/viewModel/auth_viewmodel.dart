import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:motunge/dataSource/auth.dart';
import 'package:motunge/model/auth/google_oauth_request.dart';
import 'package:motunge/model/auth/register_request.dart';
import 'package:motunge/routes/app_router.dart';

class AuthViewModel {
  Future<bool?> googleLogin() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    await FirebaseMessaging.instance.requestPermission();
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    final request = GoogleOAuthLoginRequest(
      accessToken: googleAuth.accessToken!,
      deviceToken: fcmToken,
    );

    final loginResponse = await AuthDataSource().googleLogin(request);

    await AppRouter.authNotifier.login(loginResponse);

    final isUserRegisterResponse = await AuthDataSource().checkRegister();

    return isUserRegisterResponse.isUserRegistered;
  }

  Future<void> register(String nickname) async {
    await AuthDataSource().register(RegisterRequest(nickname: nickname));
  }
}

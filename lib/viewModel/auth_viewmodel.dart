import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:motunge/dataSource/auth.dart';
import 'package:motunge/model/auth/google_oauth_request.dart';

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

    FlutterSecureStorage()
        .write(key: 'accessToken', value: loginResponse.accessToken);
    FlutterSecureStorage()
        .write(key: 'refreshToken', value: loginResponse.refreshToken);

    final isUserRegisterResponse = await AuthDataSource().checkRegister();

    return isUserRegisterResponse.isUserRegistered;
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:motunge/dataSource/auth.dart';
import 'package:motunge/model/auth/google_oauth_request.dart';
import 'package:motunge/model/auth/google_oauth_response.dart';

class AuthViewModel {
  Future<GoogleOAuthLoginResponse?> googleLogin() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication? googleAuth =
        await googleUser.authentication;

    if (googleAuth?.accessToken == null) {
      return null;
    }

    await FirebaseMessaging.instance.requestPermission();
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    final request = GoogleOAuthLoginRequest(
      accessToken: googleAuth!.accessToken!,
      deviceToken: fcmToken,
    );

    final response = await AuthDataSource().googleLogin(request);
    print(response.accessToken);
    return response;
  }
}

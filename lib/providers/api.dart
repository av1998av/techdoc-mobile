import 'package:android/helpers/shared_pref_helper.dart';

class Api{
  static Future<void> loginUser() async {
    String token = "random string";
    await SharePreferenceHelper.setUserToken(token);
  }
}
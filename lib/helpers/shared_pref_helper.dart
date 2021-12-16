import 'package:shared_preferences/shared_preferences.dart';

class SharePreferenceHelper{
  
  static Future<bool> setUserToken(String token) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString("token", token);
  }
  
  static Future<String> getUserToken() async{
    final pref = await SharedPreferences.getInstance();
    return pref.getString("token") ?? '';
  }
  
  static Future<bool> logout() async {
    final pref = await SharedPreferences.getInstance();
    return pref.clear();
  }
   
}
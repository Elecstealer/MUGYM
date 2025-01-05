import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8000/auth';

  Future<String?> login() async {
    final loginUrl = Uri.parse('$baseUrl/login/');

    try {
      if (await canLaunchUrl(loginUrl)) {
        await launchUrl(loginUrl);
      } else {
        throw 'Could not launch login URL';
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  Future<String?> getAccessToken(String code) async {
    final callbackUrl = Uri.parse('$baseUrl/callback/?code=$code');

    try {
      final response = await http.get(callbackUrl);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['access_token'];
      } else {
        print('Callback failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during token retrieval: $e');
      return null;
    }
  }
}

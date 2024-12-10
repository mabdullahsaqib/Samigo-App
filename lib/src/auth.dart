import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email', // Scope for accessing user's email
      'https://www.googleapis.com/auth/gmail.readonly', // Gmail API scope
      'https://www.googleapis.com/auth/gmail.send', // Gmail API scope
    ],
  );

  Future<String?> authenticateAndGetToken() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      print('Account: $account');
      if (account == null) {
        // User canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      print('Auth: ${auth}');
      print('Access Token: ${auth.accessToken}');
      return auth.accessToken; // Return the access token
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAuthDetails() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        return null; // User canceled the sign-in
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final authClient = await clientViaUserConsent(
        ClientId(
          dotenv.env['CLIENT_ID']!,
          dotenv.env['CLIENT_SECRET']!,
        ),
        _googleSignIn.scopes,
        (url) {
          // Open the URL in a browser or WebView
        },
      );

      return {
        'token': auth.accessToken,
        'refresh_token': authClient.credentials.refreshToken,
        'token_uri': 'https://oauth2.googleapis.com/token',
        'client_id': dotenv.env['CLIENT_ID']!,
        'client_secret': dotenv.env['CLIENT_SECRET']!,
        'scopes': _googleSignIn.scopes,
        'universe_domain': 'googleapis.com',
        'account': account.email,
        'expiry': authClient.credentials.accessToken.expiry.toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<bool> isSignedIn() async {
    return _googleSignIn.isSignedIn();
  }

  Future<GoogleSignInAccount?> getCurrentUser() async {
    return _googleSignIn.currentUser;
  }
}

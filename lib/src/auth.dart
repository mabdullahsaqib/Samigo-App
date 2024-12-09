import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email', // Scope for accessing user's email
      'https://www.googleapis.com/auth/gmail.readonly', // Gmail API scope
    ],
  );

  Future<String?> authenticateAndGetToken() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        // User canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      return auth.accessToken; // Return the access token
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 Register with Email & Password
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception("This email is already registered. Try logging in or resetting your password.");
      } else if (e.code == 'invalid-email') {
        throw Exception("The email address is not valid.");
      } else if (e.code == 'weak-password') {
        throw Exception("Password is too weak. Use at least 6 characters.");
      } else {
        throw Exception("Registration failed: ${e.message}");
      }
    } catch (e) {
      throw Exception("Unexpected error during registration: $e");
    }
  }

  /// 🔹 Login with Email & Password
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception("No account found with this email.");
      } else if (e.code == 'wrong-password') {
        throw Exception("Incorrect password. Please try again.");
      } else if (e.code == 'invalid-email') {
        throw Exception("Invalid email format.");
      } else {
        throw Exception("Login failed: ${e.message}");
      }
    } catch (e) {
      throw Exception("Unexpected error during login: $e");
    }
  }

  /// 🔹 Forgot Password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception("No account found with this email.");
      } else if (e.code == 'invalid-email') {
        throw Exception("Invalid email format.");
      } else {
        throw Exception("Password reset failed: ${e.message}");
      }
    }
  }

  /// 🔹 Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// 🔹 Get current user
  User? get currentUser => _auth.currentUser;
}

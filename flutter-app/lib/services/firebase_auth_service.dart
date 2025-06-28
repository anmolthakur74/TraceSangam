import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService {
  static FirebaseAuth? _auth;
  static String? _verificationId;
  static int? _resendToken;

  // Initialize Firebase Auth safely
  static FirebaseAuth? get auth {
    try {
      if (Firebase.apps.isNotEmpty) {
        _auth ??= FirebaseAuth.instance;
        return _auth;
      }
      return null;
    } catch (e) {
      print('Firebase Auth initialization error: $e');
      return null;
    }
  }

  // Check if Firebase is available
  static bool get isFirebaseAvailable {
    return Firebase.apps.isNotEmpty && auth != null;
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    try {
      if (!isFirebaseAvailable) return null;
      return auth?.currentUser;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  // Check if user is signed in
  static bool isUserSignedIn() {
    try {
      if (!isFirebaseAvailable) return false;
      return auth?.currentUser != null;
    } catch (e) {
      print('Check sign in status error: $e');
      return false;
    }
  }

  // Send OTP to phone number
  static Future<bool> sendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
    required Function() onAutoVerificationCompleted,
  }) async {
    try {
      if (!isFirebaseAvailable) {
        onError('Firebase is not properly configured. Using demo mode instead.');
        return false;
      }

      // Format phone number (add country code if not present)
      String formattedPhone = phoneNumber;
      if (!phoneNumber.startsWith('+')) {
        formattedPhone = '+91$phoneNumber'; // Add India country code
      }

      print('📱 Sending OTP to: $formattedPhone');

      await auth!.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (happens on some Android devices)
          try {
            print('✅ Auto-verification completed');
            await auth!.signInWithCredential(credential);
            onAutoVerificationCompleted();
          } catch (e) {
            print('❌ Auto-verification error: $e');
            onError('Auto-verification failed. Please try demo mode.');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ Verification failed: ${e.code} - ${e.message}');
          String errorMessage = 'Firebase configuration error. Using demo mode.';

          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Invalid phone number format';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Please try again later';
              break;
            case 'quota-exceeded':
              errorMessage = 'SMS quota exceeded. Please try again later';
              break;
            case 'network-request-failed':
              errorMessage = 'Network error. Please check your connection';
              break;
            case 'app-not-authorized':
            case 'invalid-api-key':
              errorMessage = 'Firebase not configured properly. Using demo mode.';
              break;
            default:
              errorMessage = 'Firebase error. Switching to demo mode.';
          }

          onError(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          print('✅ Code sent successfully. Verification ID: ${verificationId.substring(0, 10)}...');
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent('OTP sent successfully');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏰ Auto-retrieval timeout. Verification ID: ${verificationId.substring(0, 10)}...');
          _verificationId = verificationId;
        },
        timeout: Duration(seconds: 60),
        forceResendingToken: _resendToken,
      );

      return true;
    } on FirebaseException catch (e) {
      print('❌ Firebase Exception: ${e.code} - ${e.message}');

      // Handle specific Firebase configuration errors
      if (e.code == 'invalid-api-key' ||
          e.code == 'app-not-authorized' ||
          e.message?.contains('API key not valid') == true) {
        onError('Firebase not configured. Please use demo mode or configure Firebase properly.');
      } else {
        onError('Firebase error: ${e.message}. Switching to demo mode.');
      }
      return false;
    } catch (e) {
      print('❌ Send OTP error: $e');
      onError('Connection error. Please try demo mode.');
      return false;
    }
  }

  // Verify OTP
  static Future<bool> verifyOTP({
    required String otp,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    try {
      if (!isFirebaseAvailable) {
        onError('Firebase is not available');
        return false;
      }

      if (_verificationId == null) {
        onError('Verification ID not found. Please resend OTP');
        return false;
      }

      print('🔐 Verifying OTP: $otp');

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      UserCredential userCredential = await auth!.signInWithCredential(credential);

      if (userCredential.user != null) {
        print('✅ OTP verification successful');
        onSuccess();
        return true;
      } else {
        onError('Verification failed');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth Exception: ${e.code} - ${e.message}');
      String errorMessage = 'Invalid OTP';

      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Invalid OTP. Please check and try again';
          break;
        case 'session-expired':
          errorMessage = 'OTP expired. Please request a new one';
          break;
        case 'invalid-verification-id':
          errorMessage = 'Invalid verification. Please try again';
          break;
        default:
          errorMessage = e.message ?? 'Verification failed';
      }

      onError(errorMessage);
      return false;
    } catch (e) {
      print('❌ Verification error: $e');
      onError('Verification failed: ${e.toString()}');
      return false;
    }
  }

  // Resend OTP
  static Future<bool> resendOTP({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(String) onError,
  }) async {
    return await sendOTP(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onError: onError,
      onAutoVerificationCompleted: () {},
    );
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      if (isFirebaseAvailable) {
        await auth!.signOut();
        _verificationId = null;
        _resendToken = null;
        print('✅ User signed out successfully');
      }
    } catch (e) {
      print('❌ Sign out error: $e');
    }
  }

  // Get user phone number
  static String? getUserPhoneNumber() {
    try {
      if (!isFirebaseAvailable) return null;
      return auth?.currentUser?.phoneNumber;
    } catch (e) {
      print('Get phone number error: $e');
      return null;
    }
  }

  // Get user UID
  static String? getUserUID() {
    try {
      if (!isFirebaseAvailable) return null;
      return auth?.currentUser?.uid;
    } catch (e) {
      print('Get UID error: $e');
      return null;
    }
  }
}

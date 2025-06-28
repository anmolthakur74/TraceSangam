import 'dart:math';

class AuthService {
  static String? _generatedOTP;
  static String? _phoneNumber;

  // Simulate sending OTP (in real app, integrate with SMS service like Firebase Auth)
  static Future<bool> sendOTP(String phoneNumber) async {
    try {
      // Generate 6-digit OTP
      _generatedOTP = (100000 + Random().nextInt(900000)).toString();
      _phoneNumber = phoneNumber;

      // Simulate network delay
      await Future.delayed(Duration(seconds: 2));

      // In real implementation, send SMS here
      print('OTP sent to $phoneNumber: $_generatedOTP'); // For testing

      return true;
    } catch (e) {
      return false;
    }
  }

  // Verify OTP
  static bool verifyOTP(String enteredOTP) {
    if (_generatedOTP == null) return false;
    return _generatedOTP == enteredOTP;
  }

  // Get generated OTP for testing (remove in production)
  static String? getGeneratedOTP() {
    return _generatedOTP;
  }

  // Clear OTP data
  static void clearOTPData() {
    _generatedOTP = null;
    _phoneNumber = null;
  }

  // Resend OTP
  static Future<bool> resendOTP() async {
    if (_phoneNumber == null) return false;
    return await sendOTP(_phoneNumber!);
  }
}
// TODO Implement this library.
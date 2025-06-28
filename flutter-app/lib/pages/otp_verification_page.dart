import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'scan_page.dart';
import '../services/firebase_auth_service.dart';
import '../services/auth_service.dart'; // Mock service as fallback

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final bool useFirebase;

  OTPVerificationPage({
    required this.phoneNumber,
    this.useFirebase = true,
  });

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  List<TextEditingController> otpControllers = List.generate(6, (index) => TextEditingController());
  List<FocusNode> otpFocusNodes = List.generate(6, (index) => FocusNode());
  bool isLoading = false;
  bool canResend = false;
  int resendTimer = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void startResendTimer() {
    setState(() {
      canResend = false;
      resendTimer = 30;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (resendTimer > 0) {
          resendTimer--;
        } else {
          canResend = true;
          timer.cancel();
        }
      });
    });
  }

  String getEnteredOTP() {
    return otpControllers.map((controller) => controller.text).join();
  }

  void handleOTPInput(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        otpFocusNodes[index + 1].requestFocus();
      } else {
        otpFocusNodes[index].unfocus();
        // Auto-verify when all digits are entered
        if (getEnteredOTP().length == 6) {
          handleVerifyOTP();
        }
      }
    }
  }

  void handleVerifyOTP() async {
    String enteredOTP = getEnteredOTP();

    if (enteredOTP.length != 6) {
      _showErrorDialog('Please enter complete 6-digit OTP');
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Hide keyboard
    for (var focusNode in otpFocusNodes) {
      focusNode.unfocus();
    }

    if (widget.useFirebase && FirebaseAuthService.isFirebaseAvailable) {
      // Use Firebase verification
      bool isValid = await FirebaseAuthService.verifyOTP(
        otp: enteredOTP,
        onSuccess: () {
          setState(() {
            isLoading = false;
          });
          // Navigate to scan page
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => ScanPage()),
                (route) => false,
          );
        },
        onError: (error) {
          setState(() {
            isLoading = false;
          });
          _showErrorDialog(error);
          _clearOTPFields();
        },
      );
    } else {
      // Use mock verification
      bool isValid = AuthService.verifyOTP(enteredOTP);

      setState(() {
        isLoading = false;
      });

      if (isValid) {
        // Navigate to scan page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ScanPage()),
              (route) => false,
        );
      } else {
        _showErrorDialog('Invalid OTP. Please check and try again.');
        _clearOTPFields();
      }
    }
  }

  void handleResendOTP() async {
    setState(() {
      isLoading = true;
    });

    if (widget.useFirebase && FirebaseAuthService.isFirebaseAvailable) {
      // Use Firebase resend
      bool otpSent = await FirebaseAuthService.resendOTP(
        phoneNumber: widget.phoneNumber,
        onCodeSent: (message) {
          setState(() {
            isLoading = false;
          });
          _clearOTPFields();
          startResendTimer();
          _showSuccessDialog('OTP sent successfully!');
        },
        onError: (error) {
          setState(() {
            isLoading = false;
          });
          _showErrorDialog(error);
        },
      );
    } else {
      // Use mock resend
      bool otpSent = await AuthService.resendOTP();

      setState(() {
        isLoading = false;
      });

      if (otpSent) {
        _clearOTPFields();
        startResendTimer();
        _showSuccessDialog('OTP sent successfully!');
      } else {
        _showErrorDialog('Failed to resend OTP. Please try again.');
      }
    }
  }

  void _clearOTPFields() {
    for (var controller in otpControllers) {
      controller.clear();
    }
    otpFocusNodes[0].requestFocus();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF2ECC71), size: 24),
            SizedBox(width: 8),
            Text('Success'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2ECC71)),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verify OTP',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),

                    // Header Card
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // Icon
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Color(0xFF1E90FF).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.sms,
                                color: Color(0xFF1E90FF),
                                size: 35,
                              ),
                            ),
                            SizedBox(height: 16),

                            Text(
                              'Enter Verification Code',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8),

                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'We sent a 6-digit code to\n',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                children: [
                                  TextSpan(
                                    text: widget.phoneNumber,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E90FF),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Show test OTP for mock service
                            if (!widget.useFirebase || !FirebaseAuthService.isFirebaseAvailable) ...[
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  border: Border.all(color: Colors.orange[200]!),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Demo OTP: ${AuthService.getGeneratedOTP() ?? "------"}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // OTP Input Fields Card
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(6, (index) {
                                return Container(
                                  width: 45,
                                  height: 50,
                                  child: TextField(
                                    controller: otpControllers[index],
                                    focusNode: otpFocusNodes[index],
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      counterText: '',
                                      contentPadding: EdgeInsets.zero,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Color(0xFF1E90FF), width: 2),
                                      ),
                                    ),
                                    onChanged: (value) => handleOTPInput(value, index),
                                    onTap: () {
                                      otpControllers[index].selection = TextSelection.fromPosition(
                                        TextPosition(offset: otpControllers[index].text.length),
                                      );
                                    },
                                  ),
                                );
                              }),
                            ),

                            SizedBox(height: 24),

                            // Verify Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: (getEnteredOTP().length == 6 && !isLoading)
                                    ? handleVerifyOTP
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF2ECC71),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: isLoading
                                    ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Text(
                                  'Verify OTP',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Resend OTP Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didn't receive code? ",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (canResend)
                              GestureDetector(
                                onTap: isLoading ? null : handleResendOTP,
                                child: Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1E90FF),
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              )
                            else
                              Text(
                                'Resend in ${resendTimer}s',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

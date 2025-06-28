import 'package:flutter/material.dart';
import 'otp_verification_page.dart';
import '../services/firebase_auth_service.dart';
import '../services/auth_service.dart'; // Mock service as fallback

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String phoneNumber = '';
  bool isLoading = false;
  final FocusNode _phoneFocusNode = FocusNode();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void handleLogin() async {
    if (phoneNumber.isNotEmpty && phoneNumber.length >= 10) {
      setState(() {
        isLoading = true;
      });

      _phoneFocusNode.unfocus();

      // Check if Firebase is available
      if (FirebaseAuthService.isFirebaseAvailable) {
        // Try Firebase authentication first
        bool otpSent = await FirebaseAuthService.sendOTP(
          phoneNumber: phoneNumber,
          onCodeSent: (message) {
            print('✅ Firebase OTP sent: $message');
          },
          onError: (error) {
            print('❌ Firebase failed: $error');
            // Automatically switch to demo mode
            _switchToDemoMode();
          },
          onAutoVerificationCompleted: () {
            setState(() {
              isLoading = false;
            });
            // Navigate directly to scan page if auto-verified
            Navigator.pushReplacementNamed(context, '/scan');
          },
        );

        setState(() {
          isLoading = false;
        });

        if (otpSent) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationPage(
                phoneNumber: phoneNumber,
                useFirebase: true,
              ),
            ),
          );
        }
      } else {
        // Use demo mode directly
        _switchToDemoMode();
      }
    } else {
      _showErrorDialog('Please enter a valid phone number (minimum 10 digits).');
    }
  }

  void _switchToDemoMode() async {
    print('🔄 Switching to demo mode');

    // Show demo mode dialog
    bool? useDemoMode = await _showDemoModeDialog();

    if (useDemoMode == true) {
      bool otpSent = await AuthService.sendOTP(phoneNumber);

      setState(() {
        isLoading = false;
      });

      if (otpSent) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationPage(
              phoneNumber: phoneNumber,
              useFirebase: false,
            ),
          ),
        );
      } else {
        _showErrorDialog('Failed to send demo OTP. Please try again.');
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool?> _showDemoModeDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info, color: Color(0xFF1E90FF), size: 24),
            SizedBox(width: 8),
            Text('Demo Mode'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Firebase is not configured properly. Would you like to continue in demo mode?',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demo Mode Features:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Test OTP will be shown\n• All app features work\n• No real SMS sent',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1E90FF)),
            child: Text('Use Demo Mode'),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 40),

                          // Logo and Title
                          Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Color(0xFF1E90FF),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    'TS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Tracesangam',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Welcome to Tracesangam',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              // Show Firebase status
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: FirebaseAuthService.isFirebaseAvailable
                                      ? Colors.green[50]
                                      : Colors.orange[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: FirebaseAuthService.isFirebaseAvailable
                                        ? Colors.green[200]!
                                        : Colors.orange[200]!,
                                  ),
                                ),
                                child: Text(
                                  FirebaseAuthService.isFirebaseAvailable
                                      ? '🔥 Firebase Ready'
                                      : '🔄 Demo Mode',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: FirebaseAuthService.isFirebaseAvailable
                                        ? Colors.green[700]
                                        : Colors.orange[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 40),

                          // Login Form
                          Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Phone Number',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  TextField(
                                    controller: _phoneController,
                                    focusNode: _phoneFocusNode,
                                    onChanged: (value) {
                                      setState(() {
                                        phoneNumber = value;
                                      });
                                    },
                                    keyboardType: TextInputType.phone,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => handleLogin(),
                                    maxLength: 15,
                                    style: TextStyle(fontSize: 16),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your phone number',
                                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                      prefixIcon: Icon(Icons.phone, color: Colors.grey[400], size: 20),
                                      counterText: '',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                                  ),
                                  SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: (phoneNumber.isNotEmpty && phoneNumber.length >= 10 && !isLoading)
                                          ? handleLogin
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF1E90FF),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        elevation: 2,
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
                                        'Send OTP',
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

                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

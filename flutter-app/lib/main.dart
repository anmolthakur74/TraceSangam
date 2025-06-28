import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/login_page.dart';
import 'pages/scan_page.dart';
import 'services/firebase_auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with proper configuration
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
    // Continue with app launch even if Firebase fails
  }

  runApp(TracesangamApp());
}

class TracesangamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracesangam Agent App',
      theme: ThemeData(
        primaryColor: Color(0xFF1E90FF),
        scaffoldBackgroundColor: Color(0xFFF9F9F9),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: FirebaseInitWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FirebaseInitWrapper extends StatefulWidget {
  @override
  _FirebaseInitWrapperState createState() => _FirebaseInitWrapperState();
}

class _FirebaseInitWrapperState extends State<FirebaseInitWrapper> {
  bool _isFirebaseInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      // Test Firebase configuration by checking if it's properly configured
      try {
        FirebaseAuth.instance.app.options.apiKey;
        if (FirebaseAuth.instance.app.options.apiKey.startsWith('your-')) {
          throw Exception('Firebase not configured with real values');
        }
      } catch (e) {
        throw Exception('Firebase configuration incomplete');
      }

      setState(() {
        _isFirebaseInitialized = true;
      });

      print('✅ Firebase initialization completed');
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
      print('❌ Firebase initialization failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        backgroundColor: Color(0xFFF9F9F9),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Demo Mode',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Firebase is not configured. The app will run in demo mode with test OTP.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Demo Mode Features:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• Test OTP will be displayed\n• All app features work normally\n• No real SMS messages sent\n• Perfect for testing',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Continue in Demo Mode',
                      style: TextStyle(
                        color: Colors.white,
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
      );
    }

    if (!_isFirebaseInitialized) {
      return Scaffold(
        backgroundColor: Color(0xFFF9F9F9),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E90FF)),
              ),
              SizedBox(height: 20),
              Text(
                'Initializing Tracesangam...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AuthWrapper();
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuthService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Color(0xFFF9F9F9),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E90FF)),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return ScanPage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:openai/features/chat/chatScreen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    // Check if the user is already signed in
    checkCurrentUser();
  }

  Future<void> checkCurrentUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      // User is already signed in, navigate to the home screen
      navigateToHome();
    }
  }

  void navigateToHome() {
    Navigator.pushReplacementNamed(context, '/chat');
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        // Obtain the auth details from the Google SignIn object
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Create a new credential using the obtained auth details
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credential
        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        return userCredential;
      }
    } catch (error) {
      print('Google Sign-In Error: $error');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Sign in with Google
            final UserCredential? userCredential = await _signInWithGoogle();

            // Check if the login was successful
            if (userCredential != null) {
              // Navigate to the home page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
            } else {
              // Show an error message or handle the login failure
              // For example, display a snackbar or show an alert dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Login failed. Please try again.'),
                ),
              );
            }
          },
          child: Text('Sign In with Google'),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

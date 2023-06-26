import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:openai/features/auth/AuthRepositry.dart';
import 'package:openai/features/chat/chatScreen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {


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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
        // sign in 
            final UserCredential? userCredential =
                await authRepositoryInstance.signInWithGoogle();
// if user is not null , then go to chatscreen
            if (userCredential != null) {
              // Navigate to the home page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
            } else {
           // else show error
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


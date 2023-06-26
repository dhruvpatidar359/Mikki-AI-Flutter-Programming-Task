import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../login/Login.dart';

const openAIEndpoint = 'https://api.openai.com/v1/chat/completions';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  late QuerySnapshot querySnapshot;

  String _response = '';

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    _user = _auth.currentUser;
    if (_user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    });
      // User not logged in
      // Implement your login logic here
    }
  }

  Future<void> _signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully.'),
        ),
      );
    } catch (error) {
      print('Google Sign-Out Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout failed. Please try again.'),
        ),
      );
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.isNotEmpty) {
      setState(() {
        _response = 'Loading...';
      });

      final response = await http.post(Uri.parse(openAIEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                'Bearer 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',
          },
          body: jsonEncode({
            "model": "gpt-3.5-turbo",
            "messages": [
              {"role": "system", "content": "You are a helpful assistant."},
              {"role": "user", "content": message}
            ]
          }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final completion =
            data['choices'][0]['message']['content'].toString().trim();

        setState(() {
          _response = completion;
        });
      } else {
        setState(() {
          _response = 'Error: ${response.statusCode}';
        });
      }
    }
  }

  Future<void> _saveResponse() async {
    final response = _response.trim();
    if (response.isNotEmpty && _user != null) {
      await _firestore.collection('responses').add({
        'userId': _user!.uid,
        'response': response,
        'timestamp': DateTime.now(),
      });

      setState(() {
        _response = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Response saved to Firestore.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Response was empty or user not logged in.'),
        ),
      );
    }
  }

  Future<void> _showSavedResponses() async {
    if (_user != null) {
      print(" iam working");
      querySnapshot = await _firestore
          .collection('responses')
          .where('userId', isEqualTo: _user!.uid)
          // .orderBy('timestamp', descending: false)
          .get();
    }
    // print(querySnapshot.docs[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
        actions: [
          IconButton(
              onPressed: () async {
             await   _signOutGoogle();
              },
              icon: Icon(Icons.logout)),
          IconButton(
              onPressed: () async{
             await   _showSavedResponses();
                Navigator.pushNamed(context, '/showchat',
                    arguments: querySnapshot);

                // showDialog(
                //     context: context,
                //     builder: (BuildContext context) {
                //       return AlertDialog(
                //         title: Text('Saved Responses'),
                //         content: SingleChildScrollView(
                //           child: ListBody(
                //             children: querySnapshot.docs.map((doc) {
                //               final response = doc['response'];
                //               final timestamp = doc['timestamp'];
                //               return ListTile(
                //                 title: Text(response),
                //                 subtitle: Text(timestamp.toString()),
                //               );
                //             }).toList(),
                //           ),
                //         ),
                //         actions: [
                //           TextButton(
                //             onPressed: () {
                //               Navigator.pop(context);
                //             },
                //             child: Text('Close'),
                //           ),
                //         ],
                //       );
                //     });
              },
              icon: Icon(Icons.history))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.0),
              reverse: true,
              children: [
                Text(_response),
              ],
            ),
          ),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).canvasColor),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _sendMessage,
                decoration: InputDecoration.collapsed(
                  hintText: 'Enter a message',
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: Colors.black,
                ),
                onPressed: () {
                  _sendMessage(_textController.text);
                  _textController.clear();
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(
                  Icons.save,
                  color: Colors.black,
                ),
                onPressed: _saveResponse,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

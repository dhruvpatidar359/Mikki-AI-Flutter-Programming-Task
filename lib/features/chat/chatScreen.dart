import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:openai/features/auth/AuthRepositry.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  User? _user;
  late QuerySnapshot querySnapshot;

  String _response = '';

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

// check if user is logged in or not
  Future<void> _initializeUser() async {
    _user = _auth.currentUser;
    if (_user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      });
    }
  }

// api call
  Future<void> _sendMessage(String message) async {
    if (message.isNotEmpty) {
      setState(() {
        _response = 'Loading...';
      });

      final response = await http.post(Uri.parse(openAIEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                'Bearer ${dotenv.env['API_KEY']}',
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

// save the response of the api
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
          content: const Text('Response was empty or user not logged in.'),
        ),
      );
    }
  }
// function to get the saved responses
  Future<void> _getSavedResponses() async {
    if (_user != null) {
      // print(" iam working");
      querySnapshot = await _firestore
          .collection('responses')
          .where('userId', isEqualTo: _user!.uid)
          .get();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
        actions: [
          IconButton(
              onPressed: () async {
                await authRepositoryInstance.signOutGoogle(context);
              },
              icon: const Icon(Icons.logout)),
          IconButton(
              onPressed: () async {
                await _getSavedResponses();
                Navigator.pushNamed(context, '/showchat',
                    arguments: querySnapshot);
              },
              icon: const Icon(Icons.history))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              reverse: true,
              children: [
                Text(_response),
              ],
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  // It is the bottom , texteditor,send and save button widget

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).canvasColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _sendMessage,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Enter a message',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(
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
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(
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

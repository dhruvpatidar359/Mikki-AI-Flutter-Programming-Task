import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShowChats extends StatefulWidget {
  const ShowChats({super.key, required this.querySnapshot});
  final QuerySnapshot querySnapshot;
  @override
  State<ShowChats> createState() => _ShowChatsState();
}

class _ShowChatsState extends State<ShowChats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Saved Response")),
      body: SingleChildScrollView(
        child: ListBody(
          children: widget.querySnapshot.docs.map((doc) {
            final response = doc['response'];
            final timestamp = doc['timestamp'];
            return ListTile(
              title: Text(response),
              subtitle: Text(timestamp.toString()),
            );
          }).toList(),
        ),
      ),
    );
  }
}

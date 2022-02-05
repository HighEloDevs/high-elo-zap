import 'package:flutter/material.dart';
import 'message_bubble.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ChatView extends StatefulWidget {
  const ChatView({Key? key}) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late FirebaseDatabase _firebaseDatabase;
  late DatabaseReference _ref;
  late StreamSubscription<DatabaseEvent> _stream;
  late Future<Database> _messagesDatabase;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> entries = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Expanded(
          child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.only(bottom: 10, top: 40),
              itemCount: entries.length,
              itemBuilder: (BuildContext context, int index) {
                return MessageBubble(
                    isMine: entries[index]['isMine'] == 0 ? false : true,
                    message: entries[index]['message'],
                    username: entries[index]['username'],
                    time: entries[index]['time']);
              }),
        ),
        Container(
          margin: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                  child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                  labelText: 'Mensagem',
                ),
              )),
              Container(
                margin: const EdgeInsets.only(left: 5),
                child: Ink(
                  decoration: const ShapeDecoration(
                    color: Colors.lightBlue,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                    onPressed: () {
                      _sendMessage(_messageController.text);
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    ));
  }

  Future<void> init() async {
    entries = await getMessages();

    _firebaseDatabase = FirebaseDatabase.instance;
    // chat_01 will be replaced by chat hash
    _ref = _firebaseDatabase.ref("chat_01/messages");
    _stream = _ref.onValue.listen((DatabaseEvent event) {
      var snapshot = event.snapshot;
      setState(() {
        Map<String, dynamic> message = {
          'username': snapshot.child("username").value.toString(),
          'message': snapshot.child("message").value.toString(),
          'time': snapshot.child("time").value.toString(),
          'isMine': 1,
        };

        if (entries.isEmpty) {
          entries.add(message);
          insertMessage(message);
        } else if (entries.first != message) {
          entries.insert(0, message);
          insertMessage(message);
        }
      });
    });
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    _messagesDatabase = openDatabase(join(await getDatabasesPath(), 'chats.db'),
        onCreate: (db, version) {
      return db.execute(
          // messages will be replaced by chat hash
          'CREATE TABLE messages( username TEXT, message TEXT, time TEXT, isMine INTEGER )');
    }, version: 1);

    final Database db = await _messagesDatabase;
    final List<Map<String, dynamic>> messages =
        // messages will be replaced by chat hash
        List<Map<String, dynamic>>.from(await db.query('messages'));
    return messages;
  }

  Future<void> insertMessage(Map<String, dynamic> message) async {
    // Get a reference to the database.
    final Database db = await _messagesDatabase;

    // messages will be replaced by chat hash
    await db.insert('messages', message,
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  void _sendMessage(String message) {
    _messageController.clear();
    final now = DateTime.now().toLocal();
    _ref.set({
      "message": message,
      "time": "${now.hour}:${now.minute}",
      // Username is going to be replaced by user hash
      "username": "Murillo",
    });
  }

  @override
  void dispose() {
    _stream.cancel();
    super.dispose();
  }

  @override
  void initState() {
    init();
    super.initState();
  }
}

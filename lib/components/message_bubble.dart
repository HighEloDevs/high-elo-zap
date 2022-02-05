import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {Key? key,
      required this.isMine,
      required this.message,
      required this.username,
      required this.time})
      : super(key: key);

  final bool isMine;
  final String message;
  final String username;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Align(
        child: Container(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 250,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 5),
              Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[200]),
                ),
              )
            ],
          ),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(isMine ? 10 : 0),
              topRight: Radius.circular(isMine ? 0 : 10),
              bottomLeft: const Radius.circular(10),
              bottomRight: const Radius.circular(10)),
          color: isMine ? Colors.lightBlue : Colors.grey[700],
        ),
      ),
    ));
  }
}

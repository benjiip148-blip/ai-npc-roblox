import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  const ChatPage({super.key, required this.chatId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final msg = TextEditingController();
  final picker = ImagePicker();

  Future<void> sendText() async {
    if (msg.text.isEmpty) return;
    await FirebaseFirestore.instance.collection("messages").add({
      "chatId": widget.chatId,
      "senderId": FirebaseAuth.instance.currentUser!.uid,
      "text": msg.text,
      "image": null,
      "time": Timestamp.now(),
    });
    msg.clear();
  }

  Future<void> sendImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final ref = FirebaseStorage.instance
        .ref("chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg");

    await ref.putFile(File(picked.path));
    final url = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection("messages").add({
      "chatId": widget.chatId,
      "senderId": FirebaseAuth.instance.currentUser!.uid,
      "image": url,
      "text": null,
      "time": Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("messages")
                  .where("chatId", isEqualTo: widget.chatId)
                  .orderBy("time")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    return ListTile(
                      title: doc["image"] != null
                          ? Image.network(doc["image"])
                          : Text(doc["text"] ?? ""),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.image), onPressed: sendImage),
              Expanded(child: TextField(controller: msg, decoration: const InputDecoration(hintText: "Mensaje 😄"))),
              IconButton(icon: const Icon(Icons.send), onPressed: sendText),
            ],
          )
        ],
      ),
    );
  }
}

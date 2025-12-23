import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendsPage extends StatelessWidget {
  const FriendsPage({super.key});

  Future<void> createPrivateChat(String otherId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final chat = await FirebaseFirestore.instance.collection("chats").add({
      "members": [uid, otherId],
      "isGroup": false,
      "name": null,
    });

    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "friends": FieldValue.arrayUnion([otherId])
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Agregar amigos")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              if (doc.id == uid) return Container();
              return ListTile(
                title: Text(doc["name"]),
                trailing: IconButton(
                  icon: const Icon(Icons.chat),
                  onPressed: () async {
                    await createPrivateChat(doc.id);
                    Navigator.pop(context);
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

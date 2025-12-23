import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  final name = TextEditingController();
  bool loading = false;

  Future<void> auth(bool register) async {
    if (email.text.isEmpty || pass.text.isEmpty) {
      show("Completa email y contraseña");
      return;
    }

    if (register && name.text.isEmpty) {
      show("Pon un nombre");
      return;
    }

    try {
      setState(() => loading = true);

      UserCredential user;

      if (register) {
        user = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: pass.text.trim(),
        );

        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.user!.uid)
            .set({
          "name": name.text.trim(),
          "email": email.text.trim(),
          "friends": [],
        });
      } else {
        user = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: email.text.trim(),
          password: pass.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      show(e.message ?? "Error de autenticación");
    } catch (e) {
      show("Error inesperado");
    } finally {
      setState(() => loading = false);
    }
  }

  void show(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: pass,
              decoration: const InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (loading) const CircularProgressIndicator(),
            if (!loading) ...[
              ElevatedButton(
                onPressed: () => auth(false),
                child: const Text("Login"),
              ),
              TextButton(
                onPressed: () => auth(true),
                child: const Text("Crear cuenta"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

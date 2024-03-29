import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Enter your email here'
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Enter your password here'
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password
                );
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
                devtools.log(userCredential.toString());
                if (mounted) {
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                }
              } on FirebaseAuthException catch (e) {
                devtools.log(e.code);
                if (e.code == 'weak-password') {
                  if (mounted) {
                    await showErrorDialog(context, 'Weak password');
                  }
                } else if (e.code == 'email-already-in-use') {
                  if (mounted) {
                    await showErrorDialog(context, 'Email is already in use');
                  }
                } else if (e.code == 'invalid-email') {
                  if (mounted) {
                    await showErrorDialog(context, 'Invalid email entered');
                  }
                } else {
                  if (mounted) {
                    await showErrorDialog(context, 'Error: ${e.code}');
                  }
                }
              } catch (e) {
                if (mounted) {
                  await showErrorDialog(context, e.toString());
                }
              }
            },
            child: const Text('Register')
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                loginRoute,
                (route) => false
              );
            },
            child: const Text('Already registered? Login here!')
          )
        ],
      ),
    );
  }
}
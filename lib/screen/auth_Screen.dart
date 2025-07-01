import 'dart:io';

import 'package:chat_app/widgets/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _isAuthenticating = false;
  var Username = '';
  File? _profileImage;

  final _firebaseAuth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || (!_isLogin && _profileImage == null)) {
      return;
    }

    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      UserCredential userCredential;

      if (_isLogin) {
        userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user-images')
            .child('${userCredential.user!.uid}.jpg');

        await storageRef.putFile(_profileImage!);
        final imageUrl = await storageRef.getDownloadURL();

        // Save user data to Firestore
        FirebaseFirestore.instance
            .collection('user')
            .doc(userCredential.user!.uid)
            .set({
              'email': _enteredEmail,
              'image_url': imageUrl,
              'username': Username,
            });
      }
      // TODO: Navigate to chat screen on success
    } on FirebaseAuthException catch (error) {
      String errorMessage = 'Authentication failed.';

      if (error.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (error.code == 'wrong-password') {
        errorMessage = 'Wrong password provided.';
      } else if (error.code == 'email-already-in-use') {
        errorMessage = 'This email is already in use.';
      } else if (error.code == 'invalid-email') {
        errorMessage = 'Invalid email address.';
      } else if (error.code == 'weak-password') {
        errorMessage = 'The password is too weak.';
      }

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong. Please try again later.'),
        ),
      );
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                child: Image.asset('assets/images/chat.png', width: 150),
              ),
              Card(
                margin: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isLogin)
                          UserImagePicker(
                            onpicked: (pickedImage) {
                              setState(() {
                                _profileImage = pickedImage;
                              });
                            },
                          ),
                        if (!_isLogin)
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Username',
                            ),
                            autocorrect: false,
                            enableSuggestions: false,
                            validator: (value) {
                              if (value == null || value.trim().length < 5) {
                                return 'username should be at least 5 character';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              Username = value!;
                            },
                          ),

                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredEmail = value!;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Password should be at least 6 characters';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredPassword = value!;
                          },
                        ),
                        const SizedBox(height: 20),
                        if (_isAuthenticating)
                          const CircularProgressIndicator(),
                        if (!_isAuthenticating)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 2,
                              foregroundColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _submit,
                            child: Text(_isLogin ? 'Login' : 'Signup'),
                          ),
                        if (!_isAuthenticating)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(
                              _isLogin
                                  ? 'Create an account'
                                  : 'I already have an account',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

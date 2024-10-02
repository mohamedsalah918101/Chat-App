import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:push_notification/zegocloud/views/home/home.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  GlobalKey<FormState> key = GlobalKey<FormState>();
  String? email;
  String? password;
  String? username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Signup"),
      ),
      body: Form(
        key: key,
        child: ListView(
          padding: EdgeInsets.all(12),
          children: [
            TextFormField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: "Username"),
              validator: ValidationBuilder().maxLength(10).build(),
              onChanged: (value) {
                username = value;
              },
            ),
            SizedBox(
              height: 12,
            ),
            TextFormField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: "Email"),
              validator: ValidationBuilder().email().maxLength(50).build(),
              onChanged: (value) {
                email = value;
              },
            ),
            SizedBox(
              height: 12,
            ),
            TextFormField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: "Password"),
              validator: ValidationBuilder().maxLength(15).minLength(6).build(),
              onChanged: (value) {
                password = value;
              },
            ),
            SizedBox(
              height: 12,
            ),
            SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () async {
                  if (key.currentState?.validate() ?? false) {
                    try {
                      UserCredential usercred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: email!, password: password!);
                      if(usercred.user != null){
                        var data = {
                          'username': username,
                          'email': email,
                          'created_at': DateTime.now(),
                        };
                        await FirebaseFirestore.instance.collection('users').doc(usercred.user!.uid).set(data);
                      }
                      if(mounted) {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => HomePage()));
                      }
                    } on FirebaseAuthException catch (e) {
                      if(e.code == 'weak-password') {
                        print("The password provided is weak");
                      } else if(e.code == 'email-already-in-use') {
                        print("The account already exists for that email");
                      }
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                child: Text("Signup"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

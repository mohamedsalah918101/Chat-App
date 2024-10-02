import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:push_notification/zegocloud/views/auth/signup.dart';
import 'package:push_notification/zegocloud/views/home/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> key = GlobalKey<FormState>();
  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Form(
        key: key,
        child: ListView(
          padding: EdgeInsets.all(12),
          children: [
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
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: email!, password: password!);
                      if(mounted) {
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => HomePage()));
                      }
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'wrong-password') {
                        print("The password provided is wrong");
                      }
                      if (e.code == 'user-not-found') {
                        print("User not found");
                      }
                    } catch (e) {
                      print(e);
                    }
                  }
                },
                child: Text("Login"),
              ),
            ),
            SizedBox(height: 12,),
            InkWell(
              onTap: (){
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SignUp()));
              },
              child: Text("Create an account"),
            )
          ],
        ),
      ),
    );
  }
}

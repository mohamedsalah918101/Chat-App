import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:push_notification/consts.dart';
import 'package:push_notification/services/alert_service.dart';
import 'package:push_notification/services/auth_service.dart';
import 'package:push_notification/services/navigation_service.dart';
import 'package:push_notification/widgets/custom_form_text_field.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  String? email, password;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  Future<void> _saveFCMToken(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 20,
              ),
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi, Welcome Back!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800
                        ),
                      ),
                      Text(
                        "Hello again, you've been missed",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          color: Colors.grey
                        ),
                      ),

                      Container(
                        height: MediaQuery.sizeOf(context).height * 0.40,
                        margin: EdgeInsets.symmetric(
                          vertical: MediaQuery.sizeOf(context).height * 0.05,
                        ),
                        child: Form(
                          key: _loginFormKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomFormTextField(
                                  hintText: "Email",
                                  height: MediaQuery.sizeOf(context).height * 0.1,
                                  validationRegExp: EMAIL_VALIDATION_REGEX,
                                  onSaved: (value){
                                    setState(() {
                                      email = value;
                                    });
                                  },
                                ),
                                CustomFormTextField(
                                  hintText: "Password",
                                  height: MediaQuery.sizeOf(context).height * 0.1,
                                  validationRegExp: PASSWORD_VALIDATION_REGEX,
                                  obscureText: true,
                                  onSaved: (value){
                                    setState(() {
                                      password = value;
                                    });
                                  },
                                ),

                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width,
                                  child: MaterialButton(
                                      onPressed: () async {
                                        if(_loginFormKey.currentState?.validate() ?? false){
                                          _loginFormKey.currentState?.save();
                                          bool result = await _authService.login(email!, password!);
                                          if(result) {
                                            _saveFCMToken(_authService.user!.uid);
                                            _navigationService.pushReplacementNamed("/home");
                                          } else {
                                            _alertService.showToast(
                                                text: "Failed to login, Please try again!",
                                              icon: Icons.error,
                                            );
                                          }
                                        }
                                      },
                                    color: Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                          color: Colors.white
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Don't have an account? "),
                        GestureDetector(
                          onTap: (){
                            _navigationService.pushNamed("/register");
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      ],
                    )
                )
              ],
            ),
          )
      ),
    );
  }
}

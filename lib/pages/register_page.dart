import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:push_notification/models/user_profile.dart';
import 'package:push_notification/services/database_service.dart';
import 'package:push_notification/services/media_service.dart';
import 'package:push_notification/services/storage_service.dart';

import '../consts.dart';
import '../services/alert_service.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import '../widgets/custom_form_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _registerFormKey = GlobalKey();
  late AuthService _authService;
  late NavigationService _navigationService;
  late MediaService _mediaService;
  late AlertService _alertService;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  String? name, email, password;
  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
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
                      "Let's, get going!",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      "Register an account using the form below",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                    ),
                    Container(
                      height: MediaQuery.sizeOf(context).height * 0.60,
                      margin: EdgeInsets.symmetric(
                        vertical: MediaQuery.sizeOf(context).height * 0.05,
                      ),
                      child: Form(
                        key: _registerFormKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                File? file = await _mediaService.getImageFromGallery();
                                if (file != null) {
                                  setState(() {
                                    selectedImage = file;
                                  });
                                }
                              },
                              child: CircleAvatar(
                                radius: MediaQuery.of(context).size.width * 0.15,
                                backgroundImage: selectedImage != null
                                    ? FileImage(selectedImage!)
                                    : NetworkImage(PLACEHOLDER_PEP) as ImageProvider,
                              ),
                            ),
                            CustomFormTextField(
                              hintText: "Name",
                              height: MediaQuery.sizeOf(context).height * 0.1,
                              validationRegExp: NAME_VALIDATION_REGEX,
                              onSaved: (value) {
                                setState(() {
                                  name = value;
                                });
                              },
                            ),
                            CustomFormTextField(
                              hintText: "Email",
                              height: MediaQuery.sizeOf(context).height * 0.1,
                              validationRegExp: EMAIL_VALIDATION_REGEX,
                              onSaved: (value) {
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
                              onSaved: (value) {
                                setState(() {
                                  password = value;
                                });
                              },
                            ),
                            SizedBox(
                              width: MediaQuery.sizeOf(context).width,
                              child: MaterialButton(
                                onPressed: () async {
                                  _alertService.showToast(
                                    text: "Please wait some seconds......",
                                    icon: Icons.back_hand,
                                  );
                                  if (_registerFormKey.currentState?.validate() ?? false) {
                                    _registerFormKey.currentState?.save();
                                    bool result = await _authService.signUp(email!, password!);
                                    if (result) {
                                      String? pfpUrl = await _storageService.uploadUserPfp(file: selectedImage!, uid: _authService.user!.uid);
                                      if(pfpUrl != null) {
                                        await _databaseService.createUserProfile(userProfile: UserProfile(uid: _authService.user!.uid, name: name, pfpUrl: pfpUrl));
                                        _saveFCMToken(_authService.user!.uid);
                                        _alertService.showToast(
                                          text: "User registered successfully!",
                                          icon: Icons.check,
                                        );
                                        _navigationService.goBack();
                                        _navigationService.pushReplacementNamed("/home");
                                      } else {
                                        throw Exception("Unable to upload user profile picture");
                                      }
                                    } else {
                                      _alertService.showToast(
                                        text: "Failed to register, Please try again!",
                                        icon: Icons.error,
                                      );
                                    }
                                  }
                                },
                                color: Theme.of(context).colorScheme.primary,
                                child: Text(
                                  "Resigter",
                                  style: TextStyle(color: Colors.white),
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
                  Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      _navigationService.goBack();
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                ],
              ))
            ],
          ),
        )));
  }
}

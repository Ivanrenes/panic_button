import 'dart:convert';
import 'dart:io' show File, Platform;
import 'package:path/path.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:panic_button_app/models/user.dart' as pb;
import 'package:panic_button_app/services/push_notifications_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isValidUser = false;
  bool _isValidOTP = false;
  bool _isReady = false;
  bool _isValidatingOTP = false;
  bool _isLogging = false;
  bool get isLogging => _isLogging;
  String _imagePath = '';
  bool _isRegistered = false;

  bool get isRegistered => _isRegistered;

  set isRegistered(bool isRegistered) {
    _isRegistered = isRegistered;
    notifyListeners();
  }

  String get imagePath => _imagePath;

  set imagePath(String imagePath) {
    _imagePath = imagePath;
    notifyListeners();
  }

  set isLogging(bool isLogging) {
    _isLogging = isLogging;
  }

  Map<String, dynamic> dataFromUsers = {};
  late pb.User _userLogged;

  pb.User get userLogged => _userLogged;

  set userLogged(pb.User userLogged) {
    _userLogged = userLogged;
    notifyListeners();
  }

  set userLoggedUnNotified(pb.User userLogged) {
    _userLogged = userLogged;
  }

  bool get isValidatingOTP => _isValidatingOTP;

  set isValidatingOTP(bool isValidatingOTP) {
    _isValidatingOTP = isValidatingOTP;
    notifyListeners();
  }

  String _errorMessage = '';

  String get errorMessage => _errorMessage;

  set errorMessage(String errorMessage) {
    _errorMessage = errorMessage;
    notifyListeners();
  }

  bool get isReady => _isReady;

  set isReady(bool isReady) {
    _isReady = isReady;
    notifyListeners();
  }

  String verificationCode = '';

  set isValidUser(bool val) {
    _isValidUser = val;
    notifyListeners();
  }

  bool get isValidUser => _isValidUser;

  set isValidOTP(bool val) {
    _isValidOTP = val;
    notifyListeners();
  }

  bool get isValidOTP => _isValidOTP;

  Future verifyOtp(otpCode, userData) async {
    final _prefs = await SharedPreferences.getInstance();
    try {
      await _auth
          .signInWithCredential(PhoneAuthProvider.credential(
              verificationId: verificationCode, smsCode: otpCode))
          .then((user) async => {
                if (user != null)
                  {
                    if (userData != null)
                      {
                        userData.user_uid = _auth.currentUser!.uid,
                        await _firestore
                            .collection('users')
                            .doc(_auth.currentUser!.uid)
                            .set(userData.toJson(), SetOptions(merge: true))
                            .then((value) =>
                                {userLogged = userData, isLogging = false})
                            .catchError((onError) => {
                                  errorMessage = errorMessage.toString(),
                                  debugPrint('Error saving user to db.' +
                                      onError.toString())
                                })
                      }
                    else
                      {
                        await _firestore
                            .collection('users')
                            .doc(_auth.currentUser!.uid)
                            .get()
                            .then((value) => {
                                  userLogged = pb.User.fromJson(value.data()!),
                                  _prefs.setString("userLogged",
                                      json.encode(userLogged.toJson())),
                                  isValidOTP = true,
                                  isLogging = true
                                })
                            .catchError((onError) => {
                                  errorMessage = errorMessage.toString(),
                                  debugPrint('Error saving user to db.' +
                                      onError.toString()),
                                  isValidOTP = false
                                }),
                        //CHECK IF THE DEVICE IS ALREADY REGISTERED
                        userLogged.devices
                                .where((device) =>
                                    device["device"] ==
                                    PushNotificationService.token)
                                .toList()
                                .isEmpty
                            ? await _firestore
                                .collection('users')
                                .doc(_auth.currentUser!.uid)
                                .update({
                                "devices": [
                                  ...userLogged.devices,
                                  {
                                    "device": PushNotificationService.token,
                                    "os":
                                        Platform.isAndroid ? "android" : "ios",
                                    "created":
                                        DateTime.now().millisecondsSinceEpoch
                                  }
                                ]
                              }).catchError((onError) => {
                                      errorMessage = errorMessage.toString(),
                                      debugPrint('Error saving user to db.' +
                                          onError.toString())
                                    })
                            : null
                      }
                  }
              })
          .catchError(
              (onError) => {print('error ${onError}'), isValidOTP = false});
      isValidOTP = true;
    } catch (e) {
      isValidOTP = false;
      print(e);
    }
  }

  Future login(phoneNumber) async {
    //first we will check if a user with this cell number exists
    await _firestore
        .collection('users')
        .where('phone', isEqualTo: phoneNumber)
        .get()
        .then((result) {
          if (result.docs.length > 0) {
            isValidUser = true;
          }
        });

    if (isValidUser) {
      //ok, we have a valid user, now lets do otp verification
      Future<void> verifyPhoneNumber = _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (phoneAuthCredential) {
          print("Verification Completed");
        },
        verificationFailed: (FirebaseAuthException error) {
          print(error);
        },
        codeSent: (verificationId, [forceResendingToken]) {
          print(verificationId);
          verificationCode = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationCode = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
      await verifyPhoneNumber;
    } else {
      //non valid user
      return 'Number not found, please sign up first';
    }
  }

  Future signUp(userData) async {
    //first we will check if a user with this cell number exists

    //ok, we have a valid user, now lets do otp verification
    Future<void> verifyPhoneNumber = _auth.verifyPhoneNumber(
      phoneNumber: userData.phone,
      verificationCompleted: (phoneAuthCredential) {},
      verificationFailed: (FirebaseAuthException error) {
        print(error);
      },
      codeSent: (verificationId, [forceResendingToken]) {
        verificationCode = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        verificationCode = verificationId;
      },
      timeout: const Duration(seconds: 60),
    );
    await verifyPhoneNumber;
  }

  Future<void> logout() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setBool('userLogged', false);
    await _auth.signOut();
  }

  //UPLOAD IMAGE TO FIREBASE
  Future uploadImageToFirebase(BuildContext context, File imageFile) async {
    String fileName = basename(imageFile.path);
    Reference ref = _storage.ref().child('uploads/avatars/$fileName');
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    await taskSnapshot.ref.getDownloadURL().then(
          (value) =>  imagePath = value
        );
  }

  Future updateProfilePicture(String imagePath) async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({"avatar": imagePath}).then((result) {});
  }

  Future verifyIsRegistered(phoneNumber) async {
    await _firestore
        .collection('users')
        .where('phone', isEqualTo: phoneNumber)
        .get()
        .then((result) {
      if (result.docs.length > 0) {
        isRegistered = true;
      } else {
        isRegistered = false;
      }
    });
  }

  Future<bool> updateUser(email, alias, address, name, lastname) async {
    bool success = false;
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({
          "email": email,
          "alias": alias,
          "address": address,
          "name": name,
          "lastname": lastname,
        })
        .then((value) => {success = true})
        .catchError((onError) {
          success = false;
        });
    return success;
  }
}

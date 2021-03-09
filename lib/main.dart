import 'dart:async';
import 'dart:io';

import 'package:caller_app/controllers/services/caller_service.dart';
import 'package:caller_app/screens/screens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

void main() {
  runApp(MaterialApp(
    navigatorKey: navigatorKey,
    title: 'Gadri Video Caller App Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        color: Colors.white10,
        elevation: 0,
        brightness: Brightness.light,
      ),
    ),
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<FirebaseApp> _initialization;

  CallerService _callerService = CallerService();

  @override
  void initState() {
    super.initState();

    _initialization = Firebase.initializeApp().then((firebaseRes) {
      notificationHandler();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SignUp()));
      return firebaseRes;
    });

    _callerService.init();
  }

  void notificationHandler() async {
    RemoteMessage initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

//    // Also handle any interaction when the app is in the background via a
//    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('On message Opened app');
      if (message.data['type'] == 'chat') {}
    });

    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      Map<String, dynamic> data = message.data;

      _callerService..callToken = data['token'];
      _callerService..channelName = data['channelName'];

      _callerService.displayIncomingCall(context);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) async {
      Map<String, dynamic> data = remoteMessage.data;

      _callerService..callToken = data['token'];
      _callerService..channelName = data['channelName'];

      _callerService.displayIncomingCall(context);
    });

    if (Platform.isIOS)
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
  }

  @override
  Widget build(BuildContext context) {
    //For setting build context in the CallerService class
    _callerService..context = context;

    return Scaffold();
  }
}

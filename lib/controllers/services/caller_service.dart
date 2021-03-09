import 'dart:async';

import 'package:caller_app/screens/screens.dart';
import 'package:callkeep/callkeep.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CallerService {
  final FlutterCallkeep _callKeep = FlutterCallkeep();

  Map<String, Call> calls = {};

  String newUUID() => Uuid().v4();

  String callToken = '';
  String channelName = '';
  BuildContext context;

  CallerService({this.callToken, this.channelName, this.context});

  void removeCall(String callUUID) {
    calls.remove(callUUID);
  }

  Future<void> answerCall(CallKeepPerformAnswerCallAction event) async {
    final String callUUID = event.callUUID;

    final String number = calls[callUUID]?.number ?? newUUID();

    _callKeep.startCall(event.callUUID, number, number).then((value) {
      _callKeep.backToForeground();

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallPage(
              callToken: callToken,
              channelName: channelName,
            ),
          ));
    });
    Timer(const Duration(seconds: 1), () {
      print('[setCurrentCallActive] $callUUID, number: $number');
      _callKeep.setCurrentCallActive(callUUID).then((value) {
        //End the call here and manipulate the call actions with Agora's call actions
        _callKeep.endCall(callUUID);
      });
    });
  }

  Future<void> endCall(CallKeepPerformEndCallAction event) async {
    print('endCall: ${event.callUUID}');

    ///When the one you are calling rejects the call, make an action here,
    ///You can send data/silent notification back to the caller informing him/her his/her call was rejected

    removeCall(event.callUUID);
  }

  Future<void> didPerformDTMFAction(CallKeepDidPerformDTMFAction event) async {
    print('[didPerformDTMFAction] ${event.callUUID}, digits: ${event.digits}');
  }

  Future<void> didReceiveStartCallAction(
      CallKeepDidReceiveStartCallAction event) async {
    if (event.handle == null) {
      // @TODO: sometime we receive `didReceiveStartCallAction` with handle` undefined`
      return;
    }
    final String callUUID = event.callUUID ?? newUUID();

    calls[callUUID] = Call(event.handle);

    print('[didReceiveStartCallAction] $callUUID, number: ${event.handle}');

    _callKeep.startCall(callUUID, event.handle, event.handle);

    Timer(const Duration(seconds: 1), () {
      print('[setCurrentCallActive] $callUUID, number: ${event.handle}');
      _callKeep.setCurrentCallActive(callUUID);
    });
  }

  Future<void> updateDisplay(String callUUID) async {
    final String number = calls[callUUID].number;
    // Workaround because Android doesn't display well displayName, se we have to switch ...
    if (isIOS) {
      _callKeep.updateDisplay(callUUID,
          displayName: 'New Name', handle: number);
    } else {
      _callKeep.updateDisplay(callUUID,
          displayName: number, handle: 'New Name');
    }

    print('[updateDisplay: $number] $callUUID');
  }

  Future<void> displayIncomingCall(context) async {
    final String callUUID = newUUID();

    calls[callUUID] = Call(channelName);

    print('Display incoming call now');
    final bool hasPhoneAccount = await _callKeep.hasPhoneAccount();

    if (!hasPhoneAccount) {
      await _callKeep.hasDefaultPhoneAccount(context, <String, dynamic>{
        'alertTitle': 'Permissions required',
        'alertDescription':
            'This application needs to access your phone accounts',
        'cancelButton': 'Cancel',
        'okButton': 'ok',
      });
    }

    print('[displayIncomingCall] $callUUID number: $channelName');
    _callKeep.displayIncomingCall(callUUID, channelName,
        handleType: 'number', hasVideo: true);
  }

  void didDisplayIncomingCall(CallKeepDidDisplayIncomingCall event) {
    var callUUID = event.callUUID;
    var number = event.handle;
    print('[displayIncomingCall] $callUUID number: $number');

    calls[callUUID] = Call(number);
  }

  void onPushKitToken(CallKeepPushKitToken event) {
    print('[onPushKitToken] token => ${event.token}');
  }

  ///Initialize the Caller Service
  void init() {
    _callKeep.on(CallKeepDidDisplayIncomingCall(), didDisplayIncomingCall);
    _callKeep.on(CallKeepPerformAnswerCallAction(), answerCall);
    _callKeep.on(CallKeepDidPerformDTMFAction(), didPerformDTMFAction);
    _callKeep.on(
        CallKeepDidReceiveStartCallAction(), didReceiveStartCallAction);
    _callKeep.on(CallKeepPerformEndCallAction(), endCall);
    _callKeep.on(CallKeepPushKitToken(), onPushKitToken);

    _callKeep.setup(<String, dynamic>{
      'ios': {
        'appName': 'GadriCaller',
      },
      'android': {
        'alertTitle': 'Permissions required',
        'alertDescription':
            'This application needs to access your phone accounts',
        'cancelButton': 'Cancel',
        'okButton': 'ok',
      },
    });
  }
}

class Call {
  Call(this.number);

  String number;
  bool held = false;
  bool muted = false;
}

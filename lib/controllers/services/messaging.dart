import 'dart:async';
import 'dart:convert';

import 'package:caller_app/controllers/constants.dart';
import 'package:http/http.dart' as http;

const String FCMUrl = 'https://fcm.googleapis.com/fcm/send';

class LetSend {
  static Future sendMessage(
      String receiverToken, callToken, channelName) async {
    try {
      final response = await http.post(
        FCMUrl,
        body: jsonEncode(
          <String, dynamic>{
//            'notification': <String, dynamic>{
//              'body': 'this is a body',
//              'title': 'this is a title',
//              "content_available": true
//            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
              'sendingTime': DateTime.now().toString(),
              'token': '$callToken',
              'channelName': '$channelName'
            },
            'to': receiverToken,
          },
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken',
        },
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch (e) {
      print('EXCEPTION $e\n');
    }
  }
}

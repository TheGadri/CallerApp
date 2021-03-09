import 'dart:io' show SocketException;

import 'package:caller_app/controllers/commons.dart';
import 'package:caller_app/controllers/network/network.dart';

const String serverUrl = 'https://callerapp.glitch.me';

class GetAgoraAccessToken {
  static Future<String> receiveToken(String channelName, {String uid}) async {
    Network _network = Network();

    _network
      ..url = '$serverUrl/access_token?channelName=$channelName&role=publisher';

    try {
      final response = await _network.getData();

      if (response.statusCode == 200) {
        var responseJson = Commons.returnResponse(response);
        return responseJson['token'];
      } else
        return null;
    } on SocketException {
      return null;
    }
  }
}

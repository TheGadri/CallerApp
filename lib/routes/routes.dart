import 'package:caller_app/screens/screens.dart';
import 'package:flutter/material.dart';

class Routes {
  static Map<String, WidgetBuilder> myRoutes() {
    return {
      SignUp.id: (context) => SignUp(),
      HomePage.id: (context) => HomePage(),
    };
  }
}

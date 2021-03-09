import 'package:caller_app/screens/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  static const String id = 'sign_up';

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  CollectionReference users;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  //Swith between SignIn and SignUp Screen Helper
  bool _isLogin = true;

  Future<FirebaseApp> _initialization;

  @override
  void initState() {
    _initialization = Firebase.initializeApp().then((value) {
      if (FirebaseAuth.instance.currentUser != null)
        FirebaseAuth.instance.authStateChanges().listen((User user) {
          if (user != null)
            //When there is an existing user proceed to the HomePage
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(),
                    settings: RouteSettings(arguments: user)));
        });

      //Retrieve all users on this app here
      users = FirebaseFirestore.instance.collection('users');
      return value;
    });

    super.initState();
  }

  Future<void> addUser() async {
    return users
        .add({
          'email': emailController.text,
          'name': nameController.text,
          'token': "token",
        })
        .then((value) => print("User Added well well"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Container();
          }
          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return SafeArea(
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin ? 'Login' : 'Sign Up',
                            style: textTheme.headline3.copyWith(
                              color: Color(0xFF303030),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Text(
                              _isLogin ? 'Sign Up' : 'Login',
                              style: textTheme.headline6
                                  .copyWith(color: Colors.grey),
                            ),
                            onPressed: () {
                              _isLogin = !_isLogin;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Material(
                      borderRadius: BorderRadius.circular(10),
                      shadowColor: Colors.grey.shade100,
                      elevation: 50,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                image: AssetImage(
                              'assets/images/gadri_logo.jpg',
                            ))),
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    Spacer(),
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: nameController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your name';
                              } else
                                return null;
                            },
                            decoration: InputDecoration(labelText: 'Username'),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: emailController,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your email';
                              }
// This is just a regular expression for email addresses
                              String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
                                  "\\@" +
                                  "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
                                  "(" +
                                  "\\." +
                                  "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
                                  ")+";
                              RegExp regExp = new RegExp(p);

                              if (regExp.hasMatch(value)) {
// So, the email is valid
                                return null;
                              }

// The pattern of the email didn't match the regex above.
                              return 'Email is not valid';
                            },
                            decoration: InputDecoration(
                              labelText: 'Email',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                            ),
                            validator: (input) {
                              if (input.isNotEmpty) {
                                if (input.length < 5)
                                  return 'Password is too short';
                                else
                                  return null;
                              } else
                                return 'Enter your password';
                            },
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                    Spacer(),
                    SizedBox(
                        width: deviceWidth,
                        child: CupertinoButton(
                          child: Text(_isLogin ? 'LOG IN' : 'REGISTER'),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              if (!_isLogin)
                                try {
                                  UserCredential userCredential =
                                      await FirebaseAuth
                                          .instance
                                          .createUserWithEmailAndPassword(
                                              email: emailController.text,
                                              password:
                                                  passwordController.text);

                                  if (userCredential.user != null) {
                                    addUser();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage()));
                                  }
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'weak-password') {
                                    print('The password provided is too weak.');
                                  } else if (e.code == 'email-already-in-use') {
                                    print(
                                        'The account already exists for that email.');
                                  }
                                } catch (e) {
                                  print(e);
                                }
                              else {
                                try {
                                  UserCredential userCredential =
                                      await FirebaseAuth
                                          .instance
                                          .signInWithEmailAndPassword(
                                              email: emailController.text,
                                              password:
                                                  passwordController.text);

                                  if (userCredential.user != null) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage()));
                                  }
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'user-not-found') {
                                    print('No user found for that email.');
                                  } else if (e.code == 'wrong-password') {
                                    print(
                                        'Wrong password provided for that user.');
                                  }
                                }
                              }
                            }
                          },
                          color: Colors.blue,
                        )),
                    Spacer(),
//                    Text('- Login with -'),
//                    SizedBox(
//                      width: deviceWidth * 0.6,
//                      child: Row(
//                        mainAxisAlignment: MainAxisAlignment.spaceAround,
//                        children: [
//                          IconButton(
//                              icon: Image.asset('assets/images/google.png'),
//                              onPressed: () {}),
//                          IconButton(
//                              icon: Image.asset('assets/images/twitter.png'),
//                              onPressed: () {}),
//                          IconButton(
//                              icon: Image.asset('assets/images/facebook.png'),
//                              onPressed: () {}),
//                        ],
//                      ),
//                    ),
//                    Spacer(),
                  ],
                ),
              ),
            );
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Container();
        },
      ),
    );
  }
}

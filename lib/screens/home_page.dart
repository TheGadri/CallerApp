import 'package:caller_app/controllers/services/access_token.dart';
import 'package:caller_app/controllers/services/messaging.dart';
import 'package:caller_app/screens/components/components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'screens.dart';

class HomePage extends StatelessWidget {
  static const String id = 'home_page';

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    CollectionReference users = FirebaseFirestore.instance.collection('users');

    final User user = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      body: Container(
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: users.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: Text("Loading..."));
              }

              return Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: RotatedBox(
                              quarterTurns: 2,
                              child: Icon(Icons.logout, size: 42)),
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                        ),
                        CircleAvatar(
                          backgroundImage:
                              AssetImage('assets/images/young_black.jpg'),
                        )
                      ],
                    ),
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
                    SizedBox(height: 10),
                    Text(
                      'Gadri Caller',
                      style: textTheme.headline5
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'A simple video caller app demo',
                      style: textTheme.bodyText1.copyWith(
                          fontWeight: FontWeight.w400, color: Colors.grey),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (BuildContext context, int index) {
                            String receiverToken =
                                snapshot.data.docs[index]['token'];
                            String channelName =
                                snapshot.data.docs[index]['name'];

                            if (user.email ==
                                snapshot.data.docs[index]['email'])
                              return SizedBox.shrink();
                            else
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: ListTile(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(5, 0, 5, 0),
                                  onTap: () async {
                                    GetAgoraAccessToken.receiveToken(
                                            snapshot.data.docs[index]['name'])
                                        .then((callToken) {
                                      print('Call token: $callToken');
                                      LetSend.sendMessage(receiverToken,
                                          callToken, channelName);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CallPage(
                                                callToken: callToken,
                                                channelName: snapshot
                                                    .data.docs[index]['name']),
                                          ));
                                    });
                                  },
                                  leading: ProfileAvatar(
                                    isActive: true,
                                    imageUrl: 'assets/images/young_black.jpg',
                                  ),
                                  title: Text(
                                    snapshot.data.docs[index]['name'],
                                    style: textTheme.subtitle1
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                      '${snapshot.data.docs[index]['email']}, Feb 21, 5.00pm'),
                                  trailing: IconButton(
                                    icon: Icon(Icons.videocam),
                                    onPressed: () {},
                                  ),
                                ),
                              );
                          }),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

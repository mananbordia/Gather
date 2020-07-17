import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:buddiesgram/widgets/PostWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimeLinePage extends StatefulWidget {
  final User gCurrentUser;
  TimeLinePage({this.gCurrentUser});

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  List<Post> posts;
  List<String> followingsList = [];
  @override
  void initState() {
    super.initState();
    retrieveTimeline();
    retrieveFollowings();
  }

  retrieveTimeline() async {
    QuerySnapshot querySnapshot = await timelineReference
        .document(widget.gCurrentUser.id)
        .collection("timelinePosts")
        .orderBy("timestamp", descending: true)
        .getDocuments();

    List<Post> allPosts = querySnapshot.documents
        .map((document) => Post.fromDocument(document))
        .toList();

    setState(() {
      this.posts = allPosts;
    });
  }

  retrieveFollowings() async {
    QuerySnapshot querySnapshot = await followingReference
        .document(currentUser.id)
        .collection("userFollowing")
        .getDocuments();
    setState(() {
      this.followingsList = querySnapshot.documents
          .map((document) => document.documentID)
          .toList();
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
        key: _scaffoldkey,
        appBar: header(
          context,
          displayAppTitle: true,
        ), //From Header Widget
        body: RefreshIndicator(
          child: createTimeline(),
          onRefresh: () => retrieveTimeline(),
        ));
  }

  createTimeline() {
    if (posts == null) {
      return circularProgress();
    } else {
      if (posts.isEmpty) {
        return Container(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Icon(
                  Icons.photo_library,
                  color: Colors.grey,
                  size: 200.0,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  "No Post",
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ));
      } else {
        return ListView(
          children: posts,
        );
      }
    }
  }
}

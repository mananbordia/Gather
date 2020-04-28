import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as tAgo;

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;

  Comment({this.username, this.userId, this.url, this.comment, this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      url: doc['url'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width * 0.7;

    return Padding(
      padding: EdgeInsets.only(bottom: 6.0),
      child: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              leading: Material(
                elevation: 10,
                shape: CircleBorder(),
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(url),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(username,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                  Container(
                    margin: EdgeInsets.only(
                      top: 5,
                      bottom: 10,
                    ),
                    width: screenWidth,
                    child: Text(comment,
                        style: TextStyle(
                          color: Colors.black,
                        )),
                  )
                ],
              ),
              subtitle: Text(
                tAgo.format(timestamp.toDate()),
                style: TextStyle(color: Colors.blueGrey),
              ),
            )
          ],
        ),
      ),
    );
  }
}

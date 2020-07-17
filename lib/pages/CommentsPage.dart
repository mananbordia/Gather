import 'package:buddiesgram/models/comment.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CommentsPage extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String postUrl;
  CommentsPage({this.postId, this.ownerId, this.postUrl});

  @override
  CommentsPageState createState() =>
      CommentsPageState(postId: postId, ownerId: ownerId, postUrl: postUrl);
}

class CommentsPageState extends State<CommentsPage> {
  final String postId;
  final String ownerId;
  final String postUrl;
  TextEditingController textEditingController = TextEditingController();

  CommentsPageState({this.postId, this.ownerId, this.postUrl});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, customTitle: "Comments"),
      body: Column(
        children: <Widget>[
          Expanded(
            child: getComments(),
          ),
          Divider(),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(currentUser.url),
            ),
            title: TextFormField(
              controller: textEditingController,
              maxLines: null,
              decoration: InputDecoration(
                  hintText: "Add a comment",
                  hintStyle: TextStyle(color: Colors.white),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey))),
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
            trailing: OutlineButton(
              onPressed: saveComments,
              borderSide: BorderSide.none,
              child: Text(
                "Post",
                style: TextStyle(
                    color: Colors.lightGreenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ),
            ),
          )
        ],
      ),
    );
  }

  saveComments() {
    if (textEditingController.text != null) {
      commentsReference.document(postId).collection("comments").add({
        "username": currentUser.username,
        "comment": textEditingController.text.trim(),
        "url": currentUser.url,
        "timestamp": DateTime.now(),
        "userId": currentUser.id,
      });

      bool isNotOwner = ownerId != currentUser.id;

      if (isNotOwner) {
        activityReference.document(ownerId).collection("feedItems").add({
          "type": "comment",
          "username": currentUser.username,
          "userId": currentUser.id,
          "timestamp": DateTime.now(),
          "url": postUrl,
          "postId": postId,
          "userProfileImg": currentUser.url,
          "timeStamp": DateTime.now(),
        });
      }
      textEditingController.clear();
    }
  }

  getComments() {
    return StreamBuilder(
        stream: commentsReference
            .document(postId)
            .collection("comments")
            .orderBy("timestamp", descending: false)
            .snapshots(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return CircularProgressIndicator();
          }
          List<Comment> comments = [];
          dataSnapshot.data.documents.forEach((document) {
            comments.add(Comment.fromDocument(document));
          });
          return ListView(
            children: comments,
          );
        });
  }
}

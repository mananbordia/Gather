import 'dart:async';

import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/CommentsPage.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/pages/ProfilePage.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
//  final String timestamp;
  final dynamic likes;
  final String username;
  final String description;
  final String location;
  final String url;

  Post(
      {this.postId,
      this.ownerId,
//      this.timestamp,
      this.likes,
      this.username,
      this.description,
      this.location,
      this.url});

  factory Post.fromDocument(DocumentSnapshot documentSnapshot) {
    return Post(
      postId: documentSnapshot["postId"],
      ownerId: documentSnapshot["ownerId"],
//      timestamp: documentSnapshot["timestamp"],
      likes: documentSnapshot["likes"],
      username: documentSnapshot["username"],
      description: documentSnapshot["description"],
      location: documentSnapshot["location"],
      url: documentSnapshot["url"],
    );
  }

  int getTotalNumberOfLikes(likes) {
    if (likes == null) {
      return 0;
    } else {
      int counter = 0;
      likes.values.forEach((eachValue) {
        if (eachValue == true) {
          counter++;
        }
      });
      return counter;
    }
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
//     timstamp: this.timestamp,

        likes: this.likes,
        username: this.username,
        description: this.description,
        location: this.location,
        url: this.url,
        likeCount: getTotalNumberOfLikes(likes),
      );
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
//  final String timestamp;
  Map likes;
  final String username;
  final String description;
  final String location;
  final String url;
  int likeCount;
  bool isLiked;
  bool showHeart = false;
  final String currentOnlineUserId = currentUser?.id;

  _PostState({
    this.postId,
    this.ownerId,
//      this.timestamp,
    this.likes,
    this.username,
    this.description,
    this.location,
    this.url,
    this.likeCount,
  });

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentOnlineUserId] == true);
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          createPostHead(),
          createPostPicture(),
          createPostFooter(),
        ],
      ),
    );
  }

  createPostHead() {
    return FutureBuilder(
      future: usersReference.document(ownerId).get(),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        } else {
          User user = User.fromDocument(dataSnapshot.data);
          bool isPostOwner = currentOnlineUserId == ownerId;
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.url),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () => displayUserProfile(context, userProfileId: user.id),
              child: Text(
                user.username,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(
              location,
              style: TextStyle(color: Colors.white),
            ),
            trailing: isPostOwner
                ? IconButton(
                    icon: Icon(
                      Icons.mode_edit,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      final snackBar = SnackBar(content: Text('Open Menu'));
                      Scaffold.of(context).showSnackBar(snackBar);
                    },
                  )
                : Text(""),
          );
        }
      },
    );
  }

  createPostPicture() {
    return GestureDetector(
      onDoubleTap: controlPostLikes,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.network(url),
          showHeart
              ? Icon(
                  Icons.favorite,
                  size: 140.0,
                  color: Colors.pink,
                )
              : Text(""),
        ],
      ),
    );
  }

  controlPostLikes() {
    bool _liked = likes[currentOnlineUserId] == true;

    if (_liked) {
      postsReference
          .document(ownerId)
          .collection("usersPosts")
          .document(postId)
          .updateData({"likes.$currentOnlineUserId": false});
      removeLike();

      setState(() {
        likeCount--;
        isLiked = false;
        likes[currentOnlineUserId] = false;
      });
    } else {
      postsReference
          .document(ownerId)
          .collection("usersPosts")
          .document(postId)
          .updateData({"likes.$currentOnlineUserId": true});
      addLike();
      setState(() {
        likeCount++;
        isLiked = true;
        likes[currentOnlineUserId] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 800), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  removeLike() {
    bool isNotPostOwner = currentOnlineUserId != ownerId;
    if (isNotPostOwner) {
      activityReference
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((document) {
        if (document.exists) {
          document.reference.delete();
        }
      });
    }
  }

  addLike() {
    bool isNotPostOwner = currentOnlineUserId != ownerId;
    if (isNotPostOwner) {
      activityReference
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "timestamp": DateTime.now(),
        "url": url,
        "postId": postId,
        "userProfileImg": currentUser.url,
      });
    }
  }

  createPostFooter() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: controlPostLikes,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: Colors.pink,
                size: 28.0,
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              onTap: () => displayCommentScreen(context,
                  postId: postId, ownerId: ownerId, url: url),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 28.0,
                color: Colors.white,
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$likeCount likes",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                "$username ",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
                child: Text(
              description,
              style: TextStyle(color: Colors.white),
            ))
          ],
        )
      ],
    );
  }

  displayCommentScreen(BuildContext context,
      {String postId, String ownerId, String url}) {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                CommentsPage(postId: postId, ownerId: ownerId, postUrl: url)));
  }

  displayUserProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(
                  userProfileId: userProfileId,
                )));
  }
}

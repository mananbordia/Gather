import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/pages/PostScreenPage.dart';
import 'package:buddiesgram/pages/ProfilePage.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as tgo;

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        customTitle: "Notifications",
      ),
      body: Container(
        child: FutureBuilder(
            future: getNotifications(),
            builder: (context, dataSnapshot) {
              if (!dataSnapshot.hasData) {
                return circularProgress();
              } else {
                return ListView(
                  children: dataSnapshot.data,
                );
              }
            }),
      ), //From Header Widget
    );
  }

  getNotifications() async {
    // Notifications has been limited
    QuerySnapshot querySnapshot = await activityReference
        .document(currentUser.id)
        .collection("feedItems")
        .orderBy("timestamp", descending: true)
        .limit(20)
        .getDocuments();
    List<NotificationsItem> notificationsItem = [];
    querySnapshot.documents.forEach((document) {
      notificationsItem.add(NotificationsItem.fromDocument(document));
    });
    return notificationsItem;
  }
}

String notificationItemText;
Widget mediaPreview;

class NotificationsItem extends StatelessWidget {
  final String username;
  final String commentData;
  final String userId;
  final String postId;
  final String userProfileImg;
  final String url;
  final String type;
  final Timestamp timestamp;

  NotificationsItem(
      {this.username,
      this.timestamp,
      this.commentData,
      this.type,
      this.postId,
      this.url,
      this.userId,
      this.userProfileImg});
  factory NotificationsItem.fromDocument(DocumentSnapshot documentSnapshot) {
    return NotificationsItem(
      username: documentSnapshot["username"],
      timestamp: documentSnapshot["timestamp"],
      postId: documentSnapshot["postId"],
      commentData: documentSnapshot["commentData"],
      type: documentSnapshot["type"],
      url: documentSnapshot["url"],
      userId: documentSnapshot["userId"],
      userProfileImg: documentSnapshot["userProfileImg"],
    );
  }

  @override
  Widget build(BuildContext context) {
    getMediaPreview(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white,
        child: ListTile(
          title: GestureDetector(
              onTap: () => displayUserProfile(context, userProfileId: userId),
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    children: [
                      TextSpan(
                          text: username,
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                        text: " $notificationItemText",
                      )
                    ]),
              )),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(
            tgo.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
        ),
      ),
    );
  }

  displayUserProfile(BuildContext context, {String userProfileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ProfilePage(
                  userProfileId: userProfileId,
                )));
  }

  getMediaPreview(context) {
    if (type == "comment" || type == "like") {
      mediaPreview = GestureDetector(
        onTap: () => displayFullPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(url))),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text("");
    }
    if (type == "comment") {
      notificationItemText = "replied : $commentData";
    } else if (type == "like") {
      notificationItemText = "liked your post";
    } else if (type == "follow") {
      notificationItemText = "started following you";
    } else {
      notificationItemText = "Something unusual occurred, $type";
    }
  }

  displayFullPost(context) {
    return Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) =>
                PostScreenPage(postId: postId, userId: userId)));
  }
}

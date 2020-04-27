import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:buddiesgram/widgets/PostWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:flutter/material.dart';

class PostScreenPage extends StatelessWidget {
  final postId;
  final userId;

  PostScreenPage({this.postId, this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: postsReference
            .document(userId)
            .collection("usersPosts")
            .document(postId)
            .get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            Post post = Post.fromDocument(dataSnapshot.data);
            return Center(
                child: Scaffold(
              appBar: header(context, customTitle: post.description),
              body: ListView(
                children: <Widget>[
                  Container(
                    child: post,
                  ),
                ],
              ),
            ));
          }
        });
  }
}

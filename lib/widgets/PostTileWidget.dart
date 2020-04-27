import 'package:buddiesgram/pages/PostScreenPage.dart';
import 'package:buddiesgram/widgets/PostWidget.dart';
import 'package:flutter/material.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile(this.post);

  displayFullPost(context) {
    return Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) =>
                PostScreenPage(postId: post.postId, userId: post.ownerId)));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Image.network(post.url),
      onTap: () => displayFullPost(context),
    );
  }
}

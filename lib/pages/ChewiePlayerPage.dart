import 'package:buddiesgram/widgets/chewiePlayerWidget.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/cupertino.dart';

class ChewPlayer extends StatefulWidget {
  @override
  _ChewPlayerState createState() => _ChewPlayerState();
}

class _ChewPlayerState extends State<ChewPlayer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ChewiePlayer"),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.all(20.0),
        children: <Widget>[
          VideoWidget(
            videoPlayerController:
                VideoPlayerController.asset("videos/video1.webm"),
            looping: false,
          )
        ],
      ),
    );
  }
}

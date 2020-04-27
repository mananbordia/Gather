import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final VideoPlayerController videoPlayerController;
  final bool looping;
  VideoWidget({this.videoPlayerController, this.looping});

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _chewieController = ChewieController(
        videoPlayerController: widget.videoPlayerController,
        aspectRatio: 16 / 9,
        autoInitialize: true,
        looping: widget.looping,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          bufferedColor: Colors.red,
          handleColor: Colors.white,
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.white, fontSize: 15.0),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      padding: EdgeInsets.all(10.0),
      child: Chewie(
        controller: _chewieController,
      ),
    );
  }

  @override
  void dispose() {
    widget.videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}

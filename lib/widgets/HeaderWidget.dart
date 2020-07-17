import 'package:flutter/material.dart';

AppBar header(context,
    {bool displayAppTitle = false,
    String customTitle,
    bool displayBackButton = true}) {
  return AppBar(
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    automaticallyImplyLeading: displayBackButton ? true : false,
    title: Text(
      displayAppTitle ? "Gather" : customTitle,
      style: TextStyle(
          color: Colors.white, fontFamily: "Signatra", fontSize: 45.0),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}

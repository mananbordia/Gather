import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as ImD;
import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/EditProfilePage.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/HeaderWidget.dart';
import 'package:buddiesgram/widgets/PostTileWidget.dart';
import 'package:buddiesgram/widgets/PostWidget.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;

  ProfilePage({this.userProfileId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String currentOnlineUserId = currentUser?.id;
  bool loading = false;
  int postCount = 0;
  List<Post> postsList = [];
  String postOrientation = "grid";
  int followersCount = 0;
  int followingCount = 0;
  bool following = false;

  void initState() {
    getAllProfilePost();
    getAllFollowers();
    getAllFollowings();
    checkIfAlreadyFollowing();
  }

  getAllFollowings() async {
    QuerySnapshot querySnapshot = await followingReference
        .document(widget.userProfileId)
        .collection("userFollowing")
        .getDocuments();

    setState(() {
      followingCount = querySnapshot.documents.length;
    });
  }

  getAllFollowers() async {
    QuerySnapshot querySnapshot = await followersReference
        .document(widget.userProfileId)
        .collection("userFollowers")
        .getDocuments();
    setState(() {
      followersCount = querySnapshot.documents.length;
    });
  }

  checkIfAlreadyFollowing() async {
    DocumentSnapshot documentSnapshot = await followersReference
        .document(widget.userProfileId)
        .collection("userFollowers")
        .document(currentOnlineUserId)
        .get();

    setState(() {
      following = documentSnapshot.exists;
    });
  }

  createProfileTopView() {
    return FutureBuilder(
        future: usersReference.document(widget.userProfileId).get(),
        builder: (context, dataSnapshot) {
          if (!dataSnapshot.hasData) {
            return circularProgress();
          }
          User user = User.fromDocument(dataSnapshot.data);
          return Padding(
              padding: EdgeInsets.all(17.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Material(
//                        elevation: 20.0,
                        shape: CircleBorder(),
                        clipBehavior: Clip.hardEdge,
                        color: Colors.white,
                        child: Ink.image(
                          image: CachedNetworkImageProvider(user.url),
                          fit: BoxFit.cover,
                          width: 90,
                          height: 90,
                          child: InkWell(
                            onTap: setProfilePic,
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  createColumns("posts", postCount),
                                  createColumns("followers", followersCount),
                                  createColumns("following", followingCount),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  createButton(),
                                ],
                              )
                            ],
                          ))
                    ],
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 13.0),
                    child: Text(
                      user.username,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      user.profileName,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(top: 3.0),
                    child: Text(
                      user.bio,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18.0,
                      ),
                    ),
                  )
                ],
              ));
        });
  }

  setProfilePic() async {
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    imageFile = await compressImage(imageFile);
    String postId = Uuid().v4();
    String profilePicUrl = await uploadImageToFirebase(imageFile, postId);
    print(profilePicUrl);
    await usersReference
        .document(currentUser.id)
        .updateData({"url": profilePicUrl.toString()});
    await savePostInfoToFireStore(url: profilePicUrl, postId: postId);
    setState(() {});
  }

  compressImage(file) async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage((file.readAsBytesSync()));
    final compressedImageFile = File('$path/im_${currentUser.username}.jpg')
      ..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 50));
    return compressedImageFile;
  }

  Future<String> uploadImageToFirebase(mFile, postId) async {
    StorageUploadTask mStorageUploadTask =
        postStorageReference.child("post_$postId.jpg").putFile(mFile);
    StorageTaskSnapshot mStorageTaskSnapshot =
        await mStorageUploadTask.onComplete;
    String mDownloadUrl = await mStorageTaskSnapshot.ref.getDownloadURL();

    return mDownloadUrl;
  }

  savePostInfoToFireStore({String url, String postId}) {
    postsReference
        .document(currentUser.id)
        .collection("usersPosts")
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": currentUser.id,
      "timestamp": DateTime.now(),
      "likes": {},
      "username": currentUser.username,
      "description": "Profile Pic Updated",
      "location": "",
      "url": url
    });
  }

  editUserProfile() {
    return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EditProfilePage(currentOnlineUserId: currentOnlineUserId)));
  }

  createButtonTitleAndFunction({String title, Function performFunction}) {
    return Container(
        child: Padding(
            padding: EdgeInsets.only(top: 3.0),
            child: FlatButton(
                onPressed: performFunction,
                child: Container(
                  width: 245.0,
                  height: 26.0,
                  child: Text(
                    title,
                    style: TextStyle(
                        color: following ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: following ? Colors.red : Colors.black,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ))));
  }

  createButton() {
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if (ownProfile) {
      return createButtonTitleAndFunction(
        title: "Edit Profile",
        performFunction: editUserProfile,
      );
    } else if (following) {
      return createButtonTitleAndFunction(
          title: "Unfollow", performFunction: controlUnfollowUser);
    } else if (!following) {
      return createButtonTitleAndFunction(
          title: "Follow", performFunction: controlFollowUser);
    }
  }

  controlUnfollowUser() {
    setState(() {
      following = false;
    });
    followersReference
        .document(widget.userProfileId)
        .collection("userFollowers")
        .document(currentOnlineUserId)
        .get()
        .then((document) {
      if (document.exists) document.reference.delete();
    });

    followingReference
        .document(currentOnlineUserId)
        .collection("userFollowing")
        .document(widget.userProfileId)
        .get()
        .then((document) {
      if (document.exists) document.reference.delete();
    });

    activityReference
        .document(widget.userProfileId)
        .collection("feedItems")
        .document(currentOnlineUserId)
        .get()
        .then((document) {
      if (document.exists) {
        document.reference.delete();
      }
    });
  }

  controlFollowUser() {
    setState(() {
      following = true;
    });
    followersReference
        .document(widget.userProfileId)
        .collection("userFollowers")
        .document(currentOnlineUserId)
        .setData({});

    followingReference
        .document(currentOnlineUserId)
        .collection("userFollowing")
        .document(widget.userProfileId)
        .setData({});

    activityReference
        .document(widget.userProfileId)
        .collection("feedItems")
        .document(currentOnlineUserId)
        .setData({
      "type": "follow",
      "ownerId": widget.userProfileId,
      "username": currentUser.username,
      "userId": currentOnlineUserId,
      "timestamp": DateTime.now(),
      "userProfileImg": currentUser.url,
    });
  }

  Column createColumns(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.white),
        ),
        Container(
            margin: EdgeInsets.only(top: 5.0),
            child: Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 16.0,
                    color: Colors.grey))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        customTitle: "Profile",
      ), //From Header Widget
      body: ListView(
        children: <Widget>[
          createProfileTopView(),
          Divider(),
          createListAndGridLayout(),
          Divider(height: 0.0),
          displayProfilePost(),
          Divider(),
        ],
      ),
    );
  }

  displayProfilePost() {
    if (loading) {
      return circularProgress();
    } else if (postsList.isEmpty) {
      return Container(
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
      ));
    } else if (postOrientation == "grid") {
      List<GridTile> gridTilesList = [];
      postsList.forEach((eachPost) {
        gridTilesList.add(GridTile(child: PostTile(eachPost)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTilesList,
      );
    } else if (postOrientation == "list") {
      return Column(
        children: postsList,
      );
    } else {
      return Column(
        children: postsList,
      );
    }
  }

  getAllProfilePost() async {
    setState(() {
      loading = true;
    });

    QuerySnapshot querySnapshot = await postsReference
        .document(widget.userProfileId)
        .collection("usersPosts")
        .orderBy("timestamp", descending: true)
        .getDocuments();
    setState(() {
      loading = false;
      postCount = querySnapshot.documents.length;
      postsList = querySnapshot.documents
          .map((documentSnapshot) => Post.fromDocument((documentSnapshot)))
          .toList();
    });
  }

  createListAndGridLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setOrientation("grid"),
          icon: Icon(Icons.grid_on),
          color: postOrientation == "grid" ? Colors.lightGreen : Colors.grey,
        ),
        IconButton(
          onPressed: () => setOrientation("list"),
          icon: Icon(Icons.list),
          color: postOrientation == "list" ? Colors.lightGreen : Colors.grey,
        ),
      ],
    );
  }

  setOrientation(String orientation) {
    setState(() {
      this.postOrientation = orientation;
    });
  }
}

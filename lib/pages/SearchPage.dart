import 'package:buddiesgram/models/user.dart';
import 'package:buddiesgram/pages/HomePage.dart';
import 'package:buddiesgram/widgets/ProgressWidget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  TextEditingController searchTextEditController = TextEditingController();
  Future<QuerySnapshot> futureSearchResults;

  clearTextFormField() {
    searchTextEditController.clear();
    setState(() {
      futureSearchResults = null;
    });
  }

  controlSearching(String searchedText) {
    Future<QuerySnapshot> allUsers = usersReference
        .where(("profileName"), isGreaterThanOrEqualTo: searchedText)
        .getDocuments();
    setState(() {
      futureSearchResults = allUsers;
    });
  }

  AppBar searchBar() {
    return AppBar(
      backgroundColor: Colors.black,
      title: TextFormField(
        style: TextStyle(fontSize: 18.0, color: Colors.white),
        controller: searchTextEditController,
        decoration: InputDecoration(
          hintText: "Search here....",
          hintStyle: TextStyle(color: Colors.grey),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          prefixIcon: Icon(
            Icons.person_pin,
            color: Colors.white,
            size: 30.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.clear,
              color: Colors.white,
            ),
            onPressed: clearTextFormField,
          ),
        ),
        onFieldSubmitted: controlSearching,
      ),
    );
  }

  Container promptUserToSearchPage() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(
              Icons.group,
              color: Colors.grey,
              size: 200.0,
            ),
            Text(
              "Search User",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 50.0,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Container userNotFound() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(
              Icons.block,
              color: Colors.grey,
              size: 100.0,
            ),
            Text(
              "No such user",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 50.0,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  displayUserFoundScreen() {
    return FutureBuilder(
      future: futureSearchResults,
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return circularProgress();
        } else {
          List<UserResult> searchUsersResult = [];
          dataSnapshot.data.documents.forEach((document) {
            User eachUser = User.fromDocument(document);
            UserResult userResult = UserResult(eachUser);
            searchUsersResult.add(userResult);
          });
          if (searchUsersResult.isNotEmpty)
            return ListView(children: searchUsersResult);
          else {
            return userNotFound();
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: searchBar(),
      body: futureSearchResults == null
          ? promptUserToSearchPage()
          : displayUserFoundScreen(),
    );
  }

  bool get wantKeepAlive => true;
}

class UserResult extends StatelessWidget {
  final User eachUser;
  UserResult(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(3.0),
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () => print("something done"),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    backgroundImage: CachedNetworkImageProvider(eachUser.url),
                  ),
                  title: Text(
                    eachUser.profileName,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    eachUser.username,
                    style: TextStyle(color: Colors.black, fontSize: 13.0),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

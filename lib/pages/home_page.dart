import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:katalk/auth/auth_service.dart';
import 'package:katalk/chat/chat_services.dart';
import 'package:katalk/pages/add_page.dart' as AddPage;
import 'package:katalk/pages/chat_page.dart';
import 'package:katalk/pages/friend_req_page.dart';
import 'package:katalk/pages/login_page.dart';
import 'package:katalk/pages/settings_page.dart';
import 'package:katalk/widgets/user_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authService = AuthService();
  final ChatServices _chatServices = ChatServices();

  // Define _friendListFuture variable
  late Future<DocumentSnapshot> _friendListFuture;

  // Method to fetch friend list data
  Future<DocumentSnapshot> _fetchFriendListData() {
    return _chatServices.getUserDocument(_authService.currentUser!.uid);
  }

  @override
  void initState() {
    super.initState();
    // Initialize _friendListFuture in initState
    _friendListFuture = _fetchFriendListData();
  }

  void refreshFriendList() {
    setState(() {
      // Reset the Future associated with the FutureBuilder
      _friendListFuture = _fetchFriendListData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        titleTextStyle: TextStyle(
          fontFamily: 'DefoFont',
          color: Color(0xffff9a53),
          fontSize: 25,
        ),
      ),
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                DrawerHeader(
                  child:
                      Image.asset("assets/images/rsz_11logo.png", width: 100),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    title:
                        Text("Chats", style: TextStyle(fontFamily: 'DefoFont')),
                    leading: Icon(Icons.chat),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    title: Text("Settings",
                        style: TextStyle(fontFamily: 'DefoFont')),
                    leading: Icon(Icons.settings),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return SettingsPage(
                          refreshCallback: refreshFriendList,
                        );
                      }));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    title: Text("Friend Requests",
                        style: TextStyle(fontFamily: 'DefoFont')),
                    leading: Icon(Icons.person_3),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (BuildContext context) {
                        return FriendRequestPage(
                            refreshCallback: refreshFriendList);
                      }));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: ListTile(
                    title: Text("Find Friends",
                        style: TextStyle(fontFamily: 'DefoFont')),
                    leading: Icon(Icons.add),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) {
                        return AddPage.AddFriendPage();
                      }));
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: ListTile(
                title:
                    Text("Log Out", style: TextStyle(fontFamily: 'DefoFont')),
                leading: Icon(Icons.logout),
                onTap: () {
                  _authService.signOut();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                },
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _friendListFuture, // Use _friendListFuture here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }

          List<String> currentUserFriends =
              (snapshot.data!['friends'] ?? []).cast<String>();

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _chatServices.getUsersByUids(currentUserFriends),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading....");
              }

              if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              }

              List<Map<String, dynamic>> userDataList = snapshot.data ?? [];

              if (userDataList.isEmpty) {
                return Center(child: Text("No friends yet"));
              }

              return ListView(
                children: userDataList
                    .map<Widget>(
                        (userData) => _buildUserListItem(userData, context))
                    .toList(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUserListItem(
      Map<String?, dynamic> userData, BuildContext context) {
    if (userData['email'] != _authService.currentUser!.email) {
      return UserTile(
        text: userData['username'],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userData['email'],
                receiverId: userData['uid'],
                username: userData['username'],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}

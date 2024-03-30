import 'package:flutter/material.dart';
import 'package:katalk/auth/auth_service.dart';
import 'package:katalk/chat/chat_services.dart';
import 'package:katalk/pages/home_page.dart';

class FriendRequestPage extends StatefulWidget {
  final VoidCallback refreshCallback; // Callback function

  const FriendRequestPage({Key? key, required this.refreshCallback})
      : super(key: key);

  @override
  _FriendRequestPageState createState() => _FriendRequestPageState();
}

class _FriendRequestPageState extends State<FriendRequestPage> {
  final _authService = AuthService();
  final _chatServices = ChatServices();

  List<Map<String, dynamic>> _friendRequests = [];

  @override
  void initState() {
    super.initState();
    _loadFriendRequests();
  }

  void _loadFriendRequests() async {
    _chatServices
        .getPendingFriendRequests(_authService.currentUser!.uid)
        .listen((requests) {
      setState(() {
        _friendRequests = requests;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'Friend Requests',
            style: TextStyle(
              color: Color(0xffff9a53),
              fontFamily: 'DefoFont',
            ),
          ),
          leading: IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (BuildContext context) {
                  return HomePage();
                }));
              },
              icon: Icon(Icons.arrow_back))),
      body: _friendRequests.isEmpty
          ? Center(
              child: Text(
                'No friend requests',
                style: TextStyle(
                  color: Color(0xffff9a53),
                  fontFamily: 'DefoFont',
                ),
              ),
            )
          : ListView.builder(
              itemCount: _friendRequests.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _friendRequests[index]['username'],
                    style: TextStyle(
                      color: Color(0xffff9a53),
                      fontFamily: 'DefoFont',
                    ),
                  ),
                  leading: Icon(Icons.person, color: Color(0xffff9a53)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Color(0xffff9a53)),
                        onPressed: () {
                          setState(() {
                            String reqID = _friendRequests[index]['requestID'];
                            _chatServices.acceptFriendRequest(reqID);
                            _loadFriendRequests();
                            // Trigger the callback to refresh the home page
                            widget.refreshCallback();
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Color(0xffff9a53)),
                        onPressed: () {
                          setState(() {
                            String reqID = _friendRequests[index]['requestID'];
                            _chatServices.rejectFriendRequest(reqID);
                            _loadFriendRequests();
                            // Refresh the home page
                            widget.refreshCallback();
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

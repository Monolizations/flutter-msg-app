import 'package:flutter/material.dart';
import 'package:katalk/auth/auth_service.dart';
import 'package:katalk/chat/chat_services.dart';
import 'package:katalk/pages/home_page.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback refreshCallback;
  const SettingsPage({Key? key, required this.refreshCallback})
      : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _authService = AuthService();
  final _chatServices = ChatServices();

  String _username = ''; // Current username
  TextEditingController _newName = TextEditingController();
  List<String> _friends = []; // List of friends

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    // Load username from Firestore
    final user = await _authService.getCurrentUser();
    if (user != null) {
      final userData = await _chatServices.getUserDocument(user.uid);
      if (userData != null && userData.exists) {
        Map<String, dynamic> data = userData.data()!;
        setState(() {
          _username = data['username'] ?? '';
        });
      } else {
        print('User data does not exist');
      }
    } else {
      print('User is null');
    }

    // Load friends
    String? currentUserId = _authService.currentUser?.uid;
    if (currentUserId != null) {
      final friends = await _chatServices.getFriends(currentUserId);
      setState(() {
        _friends = friends;
      });
    } else {
      print('Current user ID is null');
    }
  }

  // Function to update username
  void _updateUsername(String newUsername) {
    final userId = _authService.currentUser!.uid;
    _chatServices.updateUsername(userId, newUsername).then((_) {
      setState(() {
        _username = newUsername;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Username updated successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      // Refresh home page after updating username
      widget.refreshCallback();
    }).catchError((error) {
      print('Error updating username: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update username'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  // Function to delete a friend
  void _deleteFriend(String friendId) {
    final userId = _authService.currentUser!.uid;
    _chatServices.deleteFriend(userId, friendId).then((_) {
      setState(() {
        _friends.remove(friendId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Friend deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      // Refresh home page after deleting friend
      widget.refreshCallback();
    }).catchError((error) {
      print('Error deleting friend: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete friend'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "Settings",
            style: TextStyle(
              color: Color(0xffff9a53), // Orange color
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
      body: ListView(
        children: [
          ListTile(
            title: Text(
              'Username: $_username',
              style: TextStyle(
                fontFamily: 'DefoFont', // Custom font
              ),
            ),
            subtitle: Text(
              'Tap to update',
              style: TextStyle(
                color: Color(0xffff9a53), // Orange color
                fontFamily: 'DefoFont', // Custom font
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                      'Update Username',
                      style: TextStyle(
                        fontFamily: 'DefoFont', // Custom font
                      ),
                    ),
                    content: TextField(
                      controller: _newName,
                      onChanged: (value) {},
                      decoration: InputDecoration(
                        hintText: 'Enter new username',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          String newUsername = _newName.text.trim();
                          if (newUsername.isNotEmpty) {
                            _updateUsername(newUsername);
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter a valid username'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Text('Update'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text(
              'Friends',
              style: TextStyle(
                fontFamily: 'DefoFont', // Custom font
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: _friends.length,
            itemBuilder: (context, index) {
              return FutureBuilder<String?>(
                future: _chatServices.getFriendNickname(_friends[index]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasData) {
                    String? friendNickname = snapshot.data;
                    return ListTile(
                      title: Text(
                        friendNickname ?? 'Unknown',
                        style: TextStyle(
                          fontFamily: 'DefoFont', // Custom font
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteFriend(_friends[index]);
                        },
                      ),
                    );
                  } else {
                    return ListTile(
                      title: Text(
                        'Unknown',
                        style: TextStyle(
                          color: Color(0xffff9a53), // Orange color
                          fontFamily: 'DefoFont', // Custom font
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteFriend(_friends[index]);
                        },
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

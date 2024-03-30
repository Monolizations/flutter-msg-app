import 'package:flutter/material.dart';
import 'package:katalk/auth/auth_service.dart';
import 'package:katalk/chat/chat_services.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({Key? key}) : super(key: key);

  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final _authService = AuthService();
  final _chatServices = ChatServices();

  late TextEditingController _searchController;
  String _searchText = '';
  List<Map<String, dynamic>> _searchResults = [];
  Set<String> _sentRequests =
      Set(); // Set to store the UIDs of users to whom requests were sent

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Function to handle adding a friend
  void _handleAddFriend(String userId) {
    if (_sentRequests.contains(userId)) {
      // Show a message or disable the button to prevent spamming the request
      print('Friend request already sent to this user');
    } else {
      _chatServices
          .sendFriendRequest(_authService.currentUser!.uid, userId)
          .then((_) {
        // Add the user to the set of sent requests
        _sentRequests.add(userId);
      }).catchError((error) {
        print('Error sending friend request: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friend'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _chatServices.searchUsers(_searchController.text).then((results) {
                setState(() {
                  _searchResults = results;
                });
              }).catchError((error) {
                print('Error searching users: $error');
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by Username',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchText = '';
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return UserTiled(
                  text: _searchResults[index]['username'],
                  onAddFriend: () {
                    _handleAddFriend(_searchResults[index]['uid']);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Sent Friend Request',
                          style: TextStyle(fontFamily: 'DefoFont'),
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserTiled extends StatelessWidget {
  final String text;
  final Function()? onAddFriend; // Callback function for adding a friend

  const UserTiled({
    Key? key,
    required this.text,
    this.onAddFriend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text),
      onTap: null, // Disable onTap for the entire tile
      trailing: IconButton(
        icon: Icon(Icons.person_add),
        onPressed: onAddFriend, // Call onAddFriend callback when pressed
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:katalk/models/message.dart';

class ChatServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Future<void> sendMessage(String receiverID, message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentEmail,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp);

    List<String> ids = [currentUserID, receiverID];
    ids.sort();

    String chatRoomID = ids.join('_');

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();

    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> searchUsers(String searchText) async {
    List<Map<String, dynamic>> searchResults = [];

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: searchText)
          .get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> userData = doc.data();
        searchResults.add(userData);
      }

      return searchResults;
    } catch (error) {
      print('Error searching users: $error');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getPendingFriendRequests(String userId) {
    try {
      return _firestore
          .collection('friend_requests')
          .where('receiverId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending') // Filter by pending status
          .snapshots()
          .asyncMap((querySnapshot) async {
        List<Map<String, dynamic>> requests = [];
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> request = doc.data() as Map<String, dynamic>;
          String senderId = request['senderId'];
          // Fetch the user document for the sender
          DocumentSnapshot<Map<String, dynamic>> userDoc =
              await _firestore.collection('users').doc(senderId).get();
          if (userDoc.exists) {
            Map<String, dynamic> userData = userDoc.data()!;
            String senderName = userData['username'];
            request['username'] =
                senderName; // Add sender's username to the request
            requests.add(request);
          }
        }
        return requests;
      });
    } catch (error) {
      print('Error fetching pending friend requests: $error');
      throw error;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument(
      String userId) async {
    try {
      // Get the user document based on the userId
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(userId).get();
      return userDoc;
    } catch (error) {
      print('Error getting user document: $error');
      rethrow; // Rethrow the error for handling in the calling code
    }
  }

  Future<String> sendFriendRequest(String senderId, String receiverId) async {
    try {
      DocumentReference requestRef =
          await _firestore.collection("friend_requests").add({
        'senderId': senderId,
        'receiverId': receiverId,
        'status':
            'pending', // Status can be 'pending', 'accepted', or 'rejected'
        'timestamp': Timestamp.now(),
      });

      // Get the ID of the newly created friend request document
      String requestId = requestRef.id;

      // Update the same document with the requestID
      await requestRef.update({'requestID': requestId});

      // Return the ID
      return requestId;
    } catch (e) {
      print('Error sending friend request: $e');
      // Handle errors
      rethrow; // Rethrow the error for handling in the calling code
    }
  }

// Function to accept a friend request
  Future<void> acceptFriendRequest(String requestId) async {
    try {
      // Update the status of the friend request document in Firestore
      await _firestore.collection("friend_requests").doc(requestId).update({
        'status': 'accepted',
      });

      // Retrieve sender and receiver IDs
      var requestDoc =
          await _firestore.collection("friend_requests").doc(requestId).get();
      var senderId = requestDoc['senderId'];
      var receiverId = requestDoc['receiverId'];

      // Fetch sender and receiver user data
      var senderDoc = await _firestore.collection("users").doc(senderId).get();
      var receiverDoc =
          await _firestore.collection("users").doc(receiverId).get();

      // Update sender's friend list
      var senderFriendList =
          senderDoc['friends'] != null ? List.from(senderDoc['friends']) : [];
      senderFriendList.add(receiverId);
      await _firestore
          .collection("users")
          .doc(senderId)
          .update({'friends': senderFriendList});

      // Update receiver's friend list
      var receiverFriendList = receiverDoc['friends'] != null
          ? List.from(receiverDoc['friends'])
          : [];
      receiverFriendList.add(senderId);
      await _firestore
          .collection("users")
          .doc(receiverId)
          .update({'friends': receiverFriendList});

      // Optionally, you can show a confirmation message to the user
    } catch (e) {
      print('Error accepting friend request: $e');
      // Handle errors
    }
  }

  Future<List<Map<String, dynamic>>> getUsersByUids(List<String> uids) async {
    try {
      List<Map<String, dynamic>> usersData = [];

      for (String uid in uids) {
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(uid).get();
        if (userSnapshot.exists) {
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;
          usersData.add(userData);
        }
      }

      return usersData;
    } catch (e) {
      print("Error fetching users by UIDs: $e");
      return [];
    }
  }

  // Function to reject a friend request
  Future<void> rejectFriendRequest(String requestId) async {
    try {
      // Delete the friend request document from Firestore
      await _firestore.collection("friend_requests").doc(requestId).delete();

      // Optionally, you can show a confirmation message to the user

      // Reload the friend requests data to update the UI
    } catch (e) {
      print('Error rejecting friend request: $e');
      // Handle errors
    }
  }

  Future<void> deleteFriend(String userId, String friendId) async {
    try {
      // Remove friendId from the user's friend list
      await _firestore.collection('users').doc(userId).update({
        'friends': FieldValue.arrayRemove([friendId])
      });

      // Remove userId from the friend's friend list
      await _firestore.collection('users').doc(friendId).update({
        'friends': FieldValue.arrayRemove([userId])
      });

      // Optionally, you can show a confirmation message to the user
    } catch (error) {
      print('Error deleting friend: $error');
      // Handle errors
      rethrow; // Rethrow the error for handling in the calling code
    }
  }

  Future<void> updateUsername(String userId, String newUsername) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'username': newUsername,
      });
      // Optionally, you can show a confirmation message to the user
    } catch (error) {
      print('Error updating username: $error');
      // Handle errors
      rethrow; // Rethrow the error for handling in the calling code
    }
  }

  Future<List<String>> getFriends(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        List<String> friends = List<String>.from(
            userDoc['friends'] ?? []); // Convert to List<String>
        return friends;
      } else {
        return []; // Return empty list if user document doesn't exist
      }
    } catch (error) {
      print('Error getting friends: $error');
      throw error;
    }
  }

  Future<bool> checkUsernameDuplicates(String newUsername) async {
    try {
      // Query Firestore to check if the provided username already exists
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: newUsername)
          .get();

      // If there are documents with the provided username, it's a duplicate
      return snapshot.docs.isNotEmpty;
    } catch (error) {
      print('Error checking username duplicates: $error');
      throw error;
    }
  }

  Future<String?> getFriendNickname(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc['username'];
      } else {
        return null;
      }
    } catch (error) {
      print('Error getting friend nickname: $error');
      return null;
    }
  }
}

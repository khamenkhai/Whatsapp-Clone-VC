import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_testing/common/utils/utils.dart';
import 'package:vc_testing/models/user_model.dart';
import 'package:vc_testing/features/chat/screens/mobile_chat_screen.dart';

final selectContactsRepositoryProvider = Provider(
  (ref) => SelectContactRepository(
    firestore: FirebaseFirestore.instance,
  ),
);

class SelectContactRepository {
  final FirebaseFirestore firestore;

  SelectContactRepository({
    required this.firestore,
  });

  // Fetch all contacts from the device
  Future<List<Contact>> getDeviceContacts() async {
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  }

  // Fetch all UserModel objects from the Firestore "users" collection
  Future<List<UserModel>> getFirebaseUsers() async {
    List<UserModel> users = [];
    try {
      var userCollection = await firestore.collection('users').get();
      users = userCollection.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
    }
    return users;
  }

  // Select a Firebase user and navigate to the chat screen
  void selectContact(UserModel selectedUser, BuildContext context) async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MobileChatScreen(
            isGroupChat: false,
            name: selectedUser.name,
            profilePic: selectedUser.profilePic,
            uid: selectedUser.uid,
          ),
        ),
      );
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vc_testing/common/widgets/error.dart';
import 'package:vc_testing/common/widgets/loader.dart';
import 'package:vc_testing/features/select_contacts/controller/select_contact_controller.dart';
import 'package:vc_testing/models/user_model.dart';

class SelectContactsScreen extends ConsumerWidget {
  static const String routeName = '/select-contact';
  const SelectContactsScreen({Key? key}) : super(key: key);

  void selectContact(
      WidgetRef ref, UserModel selectedContact, BuildContext context) {
    ref
        .read(selectContactControllerProvider)
        .selectContact(selectedContact, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select contact a'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
            ),
          ),
        ],
      ),
      body: ref.watch(getContactsProvider).when(
            data: (contactList) => ListView.builder(
              itemCount: contactList.length,
              itemBuilder: (context, index) {
                final contact = contactList[index];
                return contact.uid != FirebaseAuth.instance.currentUser?.uid
                    ? InkWell(
                        onTap: () => selectContact(ref, contact, context),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            title: Text(
                              contact.name,
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            leading: contact.profilePic == null
                                ? null
                                : CircleAvatar(
                                    // backgroundImage: MemoryImage(contact.profilePic ?? ""),
                                    radius: 30,
                                  ),
                          ),
                        ),
                      )
                    : Container();
              },
            ),
            error: (err, trace) => ErrorScreen(error: err.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}

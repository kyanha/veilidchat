import 'package:flutter/material.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});
  static const path = '/contacts';

  @override
  Widget build(
    BuildContext context,
  ) =>
      const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Contacts Page'),
              // ElevatedButton(
              //   onPressed: () async {
              //     ref.watch(authNotifierProvider.notifier).login(
              //           "myEmail",
              //           "myPassword",
              //         );
              //   },
              //   child: const Text("Login"),
              // ),
            ],
          ),
        ),
      );
}

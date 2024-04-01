import 'package:flutter/material.dart';

class HomeAccountInvalid extends StatefulWidget {
  const HomeAccountInvalid({super.key});

  @override
  HomeAccountInvalidState createState() => HomeAccountInvalidState();
}

class HomeAccountInvalidState extends State<HomeAccountInvalid> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const Text('Account invalid');
}
// xxx: delete invalid account
        // Future.delayed(0.ms, () async {
        //   await showErrorModal(context, translate('home.invalid_account_title'),
        //       translate('home.invalid_account_text'));
        //   // Delete account
        //   await AccountRepository.instance.deleteLocalAccount(activeUserLogin);
        //   // Switch to no active user login
        //   await AccountRepository.instance.switchToAccount(null);
        // });

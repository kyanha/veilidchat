import 'package:flutter/material.dart';

class HomeAccountMissing extends StatefulWidget {
  const HomeAccountMissing({super.key});

  @override
  HomeAccountMissingState createState() => HomeAccountMissingState();
}

class HomeAccountMissingState extends State<HomeAccountMissing> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const Text('Account missing');
}

// xxx click to delete missing account or add to postframecallback
        // Future.delayed(0.ms, () async {
        //   await showErrorModal(context, translate('home.missing_account_title'),
        //       translate('home.missing_account_text'));
        //   // Delete account
        //   await AccountRepository.instance.deleteLocalAccount(activeUserLogin);
        //   // Switch to no active user login
        //   await AccountRepository.instance.switchToAccount(null);
        // });
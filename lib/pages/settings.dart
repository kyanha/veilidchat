import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});
  static const path = '/settings';

  @override
  Widget build(BuildContext context, WidgetRef ref) => const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Settings Page'),
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

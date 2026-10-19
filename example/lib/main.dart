import 'package:flutter/material.dart';
import 'package:descope/descope.dart';

void main() {
  Descope.setup('project-id', (config) {});
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: TextButton(
            onPressed: _signIn,
            child: const Text('Descope example'),
          ),
        ),
      ),
    );
  }

  // references the web flow and passkey code paths so they get compiled
  Future<void> _signIn() async {
    final options = DescopeFlowOptions(web: DescopeWebFlowOptions(flowId: 'sign-up-or-in'));
    await Descope.flow.start(options);
    await Descope.passkey.signUpOrIn(loginId: 'user@example.com');
  }
}

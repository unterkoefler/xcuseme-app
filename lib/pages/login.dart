import 'package:flutter/material.dart';
import 'package:xcuseme/authentication_service.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
          ),
        ),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
          ),
        ),
        RaisedButton(
          onPressed: () async {
            String msg = await context.read<AuthenticationService>().login(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );
            print(msg);
          },
          child: Text('Login'),
        ),
      ],
    ));
  }
}

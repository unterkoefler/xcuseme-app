import 'package:flutter/material.dart';
import 'package:xcuseme/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:xcuseme/constants/style.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<AuthenticationService>(
        create: (_) => AuthenticationService(FirebaseAuth.instance),
        child: Scaffold(
          backgroundColor: Colors.red[100],
          body: ForgotPasswordScreen(),
        ));
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailController;
  List<TextEditingController> _controllers = [];
  bool _submitEnabled;
  bool _emailSent;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    _controllers = [
      emailController,
    ];
    _submitEnabled = false;
    _emailSent = false;
  }

  @override
  void dispose() {
    _controllers.forEach((ctlr) {
      ctlr.dispose();
    });
    super.dispose();
  }

  void _updateEnabledState(String _) {
    if (_submitEnabled != _controllers.every((ctlr) => ctlr.text.isNotEmpty)) {
      setState(() {
        _submitEnabled = !_submitEnabled;
      });
    }
  }

  Widget _titleText(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Forgot Password',
          style: TextStyle(color: Colors.white, fontSize: HEADING_FONT_SIZE),
        ));
  }

  Widget _descriptionText(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
          "Enter your email and we'll send you instructions on how to reset your password."),
    );
  }

  Widget _sentEmailText(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
          'Success! Please check your email (${emailController.text.trim()}) for further instructions.'),
    );
  }

  Widget _emailInput(BuildContext context) {
    return Material(
        borderRadius: BorderRadius.circular(40),
        elevation: 10,
        child: TextField(
          controller: emailController,
          onChanged: _updateEnabledState,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: 'Email',
            prefixIcon: Icon(Icons.email, size: 24, color: Colors.teal[200]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: BorderSide.none,
            ),
          ),
        ));
  }

  Widget _submitButton(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return Colors.grey[400];
      }
      return Colors.white;
    }

    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        backgroundColor: MaterialStateProperty.resolveWith(getColor),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.indigo[600]),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0)),
      ),
      onPressed: _submitEnabled
          ? () {
              _submit(context);
            }
          : null,
      child: Text('Send Reset Email', style: TextStyle(fontSize: 18)),
    );
  }

  Widget _returnToLoginButton(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.indigo[600]),
        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0)),
      ),
      onPressed: _submitEnabled
          ? () {
              Navigator.pop(context);
            }
          : null,
      child: Text('Return to Login', style: TextStyle(fontSize: 18)),
    );
  }

  Future<void> _submit(BuildContext context) async {
    String msg = await context
        .read<AuthenticationService>()
        .sendPasswordResetEmail(email: emailController.text.trim());
    print(msg);
    if (msg != null) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } else {
      // success
      setState(() {
        _emailSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> contents = <Widget>[
      _titleText(context),
      SizedBox(height: 36),
    ];

    if (_emailSent) {
      contents.addAll(
        [
          _sentEmailText(context),
          SizedBox(height: 36),
          _returnToLoginButton(context),
        ],
      );
    } else {
      contents.addAll(
        [
          _descriptionText(context),
          SizedBox(height: 24.0),
          _emailInput(context),
          SizedBox(height: 12),
          _submitButton(context),
        ],
      );
    }

    return SafeArea(
        child: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: contents,
                ))));
  }
}

import 'package:flutter/material.dart';
import 'package:xcuseme/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:xcuseme/constants/style.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<AuthenticationService>(
        create: (_) => AuthenticationService(FirebaseAuth.instance),
        child: Scaffold(
          backgroundColor: Colors.teal[100],
          appBar: AppBar(
            title: _titleText(context),
            elevation: 0,
            flexibleSpace:
                Container(decoration: BoxDecoration(color: Colors.teal[100])),
          ),
          body: SignupScreen(),
        ));
  }

  Widget _titleText(BuildContext context) {
    return Text(
      'Create Account',
      style: TextStyle(color: Colors.white, fontSize: HEADING_FONT_SIZE),
    );
  }
}

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController emailController;
  TextEditingController passwordController;
  TextEditingController confirmPasswordController;
  List<TextEditingController> _controllers = [];
  bool _agreedToTos = false;
  bool _submitEnabled;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    _controllers = [
      emailController,
      passwordController,
      confirmPasswordController,
    ];
    _submitEnabled = false;
  }

  @override
  void dispose() {
    _controllers.forEach((ctlr) {
      ctlr.dispose();
    });
    super.dispose();
  }

  void _updateEnabledState(String _) {
    if (_submitEnabled != _agreedToTos &&
        _controllers.every((ctlr) => ctlr.text.isNotEmpty)) {
      setState(() {
        _submitEnabled = !_submitEnabled;
      });
    }
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

  Widget _passwordInput(BuildContext context) {
    return Material(
        borderRadius: BorderRadius.circular(40),
        elevation: 10,
        child: TextField(
          controller: passwordController,
          onChanged: _updateEnabledState,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon: Icon(Icons.lock, size: 24, color: Colors.red[200]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: BorderSide.none,
            ),
          ),
        ));
  }

  Widget _confirmPasswordInput(BuildContext context) {
    return Material(
        borderRadius: BorderRadius.circular(40),
        elevation: 10,
        child: TextField(
          controller: confirmPasswordController,
          onChanged: _updateEnabledState,
          onSubmitted: _submitEnabled
              ? (_) {
                  _signup(context);
                }
              : null,
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Confirm Password',
            prefixIcon: Icon(Icons.lock, size: 24, color: Colors.red[200]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: BorderSide.none,
            ),
          ),
        ));
  }

  Widget _signupButton(BuildContext context) {
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
              _signup(context);
            }
          : null,
      child: Text('Sign up', style: TextStyle(fontSize: 18)),
    );
  }

  Widget _loginText(BuildContext context) {
    return TextButton(
      child: Text("Been here before? Log in"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _tosRow(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: _agreedToTos,
        onChanged: (val) {
          setState(() {
            _agreedToTos = val;
          });
          _updateEnabledState('');
        },
      ),
      title: Text('I have read and agree to the Terms and Conditions',
          style: TextStyle(fontSize: PARAGRAPH_FONT_SIZE)),
    );
  }

  Future<void> _signup(BuildContext context) async {
    String msg = await context.read<AuthenticationService>().signup(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
        agreedToTos: _agreedToTos);
    print(msg);
    if (msg != null) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } else {
      // success
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: <Widget>[
                    _emailInput(context),
                    SizedBox(height: 12),
                    _passwordInput(context),
                    SizedBox(height: 12),
                    _confirmPasswordInput(context),
                    SizedBox(height: 12),
                    _tosRow(context),
                    SizedBox(height: 12),
                    _signupButton(context),
                    SizedBox(height: 24),
                    _loginText(context),
                  ],
                ))));
  }
}

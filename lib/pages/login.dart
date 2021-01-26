import 'package:flutter/material.dart';
import 'package:xcuseme/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:xcuseme/constants/style.dart';
import 'package:xcuseme/pages/signup.dart';
import 'package:xcuseme/pages/forgot_password.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[100],
      body: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController;
  TextEditingController passwordController;
  bool _submitEnabled;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    _submitEnabled = false;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _updateEnabledState(String text) {
    if (_submitEnabled !=
        (emailController.text.isNotEmpty &&
            passwordController.text.isNotEmpty)) {
      setState(() {
        _submitEnabled = !_submitEnabled;
      });
    }
  }

  Widget _graphic(BuildContext context) {
    return Column(
      children: <Widget>[
        Ink.image(
          image: AssetImage('assets/icons/login_icon.png'),
          height: 128.0,
          fit: BoxFit.contain,
        ),
        Text(
          'XCuseMe',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ],
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

  Widget _passwordInput(BuildContext context) {
    return Material(
        borderRadius: BorderRadius.circular(40),
        elevation: 10,
        child: TextField(
          controller: passwordController,
          onChanged: _updateEnabledState,
          onSubmitted: _submitEnabled
              ? (_) {
                  _login(context);
                }
              : null,
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

  Widget _loginButton(BuildContext context) {
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
              _login(context);
            }
          : null,
      child: Text('Login', style: TextStyle(fontSize: 18)),
    );
  }

  Widget _forgotPasswordText(BuildContext context) {
    return TextButton(
      child: Text("Forgot password?"),
      onPressed: () {
        Navigator.push(context,
            PageRouteBuilder(pageBuilder: (BuildContext context, __, ____) {
          return ForgotPasswordPage();
        }));
      },
    );
  }

  Widget _signupText(BuildContext context) {
    return TextButton(
      child: Text("New here? Sign up"),
      onPressed: () {
        Navigator.push(context,
            PageRouteBuilder(pageBuilder: (BuildContext context, __, ____) {
          return SignupPage();
        }));
      },
    );
  }

  Future<void> _login(BuildContext context) async {
    String msg = await context.read<AuthenticationService>().login(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
    print(msg);
    if (msg != null) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
                    SizedBox(height: 64.0),
                    _graphic(context),
                    SizedBox(height: 36),
                    _emailInput(context),
                    SizedBox(height: 12),
                    _passwordInput(context),
                    SizedBox(height: 6),
                    _forgotPasswordText(context),
                    SizedBox(height: 6),
                    _loginButton(context),
                    SizedBox(height: 24),
                    _signupText(context),
                  ],
                ))));
  }
}

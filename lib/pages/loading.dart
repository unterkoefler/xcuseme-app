import 'package:flutter/material.dart';
import 'package:xcuseme/constants/style.dart';

class LoadingPage extends StatelessWidget {
  Widget _loadingIndicator(BuildContext context) {
    return LinearProgressIndicator(
        value: null,
        backgroundColor: Colors.teal[300],
        valueColor: AlwaysStoppedAnimation<Color>(Colors.red[300]),
        minHeight: 14);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox.expand(
            child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: [Colors.teal[200], Colors.red[200]],
                )),
                child: Column(children: <Widget>[
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('XCuseMe',
                          style: TextStyle(
                              fontSize: LOADING_TITLE_FONT_SIZE,
                              color: Colors.deepPurple[500])),
                      SizedBox(height: 8.0),
                      Text('The exercise tracking app for real people',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: PARAGRAPH_FONT_SIZE,
                              color: Colors.black)),
                    ],
                  )),
                  _loadingIndicator(context)
                ]))));
  }
}

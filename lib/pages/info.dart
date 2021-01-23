import 'package:flutter/material.dart';
import 'package:xcuseme/constants/style.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const info_pre = """
XCuseMe is the exercise tracking app for real people. Use it to track your exercise -- and your excuses! Ever wonder how many times you've skipped your ab routine because you woke up too late? Or exactly how long that knee injury kept you on the couch? Life happens and sometimes we can't keep up, but now we can keep track.

To record a new activity, tap the "Log Excuse" or "Log Exercise" button, enter a text description of your exercise or excuse, and press "Save". Only one type of activity can be saved on a given day. If you went for a run yesterday, but skipped your core workout, you can note that in the description of your exercise and be proud that you did anything!

To ensure your privacy, all data is stored locally on your device and will never be sold to third-parties.

XCuseMe is currently in active development. To report a bug or request a feature, please create an issue on """;

    const info_post = """.

Thank you and have a good day!
    """;
    return SizedBox.expand(
        child: Container(
            decoration: BoxDecoration(color: Colors.grey[200]),
            child: SingleChildScrollView(
                child: Container(
              padding: EdgeInsets.all(24),
              child: RichText(
                  text: TextSpan(
                text: info_pre,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: PARAGRAPH_FONT_SIZE + 2,
                    height: 1.5),
                children: <TextSpan>[
                  TextSpan(
                    text: 'the Github repository',
                    style: TextStyle(
                        color: Colors.blue[800],
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch('https://github.com/unterkoefler/xcuseme');
                      },
                  ),
                  TextSpan(text: info_post),
                ],
              )),
            ))));
  }
}

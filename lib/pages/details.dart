import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:xcuseme/model.dart';
import 'package:xcuseme/constants/style.dart';
import 'package:xcuseme/constants/constants.dart';

class DetailsPage extends StatelessWidget {
  Widget _editButton(BuildContext context, Event e) {
    return IconButton(
      icon: Icon(Icons.edit, color: Colors.blue[800], size: ICON_SIZE),
      onPressed: () => Navigator.pushNamed(context, '/edit', arguments: e),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Event event = ModalRoute.of(context).settings.arguments;
    final DateTime dt = event.datetime;
    final String title = '${STRINGS[event.type]} Details';
    final Color color = TYPE_COLORS[event.type];
    String date = DateFormat.MMMMEEEEd().format(dt);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(title,
                  style: TextStyle(color: color, fontSize: HEADING_FONT_SIZE)),
              _editButton(context, event),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 24, right: 24, bottom: 8),
          child: Text(date,
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: PARAGRAPH_FONT_SIZE + 2.0)),
        ),
        Container(
          padding: EdgeInsets.only(left: 24, right: 24, top: 8),
          child: Text(event.description,
              style: TextStyle(fontSize: PARAGRAPH_FONT_SIZE)),
        ),
      ],
    );
  }
}

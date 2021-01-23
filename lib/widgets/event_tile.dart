import 'package:flutter/material.dart';
import 'package:xcuseme/constants/style.dart';
import 'package:xcuseme/constants/constants.dart';
import 'package:intl/intl.dart';
import 'package:xcuseme/model.dart';

class EventTile extends StatelessWidget {
  final Event event;

  EventTile(this.event);

  Icon _icon(BuildContext context) {
    Color color = TYPE_COLORS[event.type];
    IconData iconData = TYPE_ICONS[event.type];
    return Icon(
      iconData,
      size: ICON_SIZE,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    String date = DateFormat.Md().format(event.datetime);
    String title = "$date - ${event.description}";
    return ListTile(
      onTap: () => Navigator.pushNamed(context, '/details', arguments: event),
      leading: _icon(context),
      //dense: true,
      title: Text(
        title,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: SizedBox(
          height: double.infinity,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Details", style: TextStyle(color: Colors.blueGrey[300])),
              Icon(Icons.navigate_next,
                  size: SMALL_ICON_SIZE, color: Colors.blueGrey[300]),
            ],
          )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:xcuseme/constants/style.dart';
import 'package:xcuseme/constants/constants.dart';
import 'package:xcuseme/models/event.dart';

class CreateEventTile extends StatelessWidget {
  Widget _dialogOption(BuildContext context, EventType type) {
    String next = PATHS[type];
    String label = BUTTON_LABELS[type];
    Color color = TYPE_COLORS[type];

    return SimpleDialogOption(
      onPressed: () {
        Navigator.pushReplacementNamed(context, next);
      },
      child: Text(label,
          style: TextStyle(fontSize: SMALL_HEADING_FONT_SIZE, color: color)),
    );
  }

  Future _showDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            _dialogOption(context, EventType.EXCUSE),
            const Divider(),
            _dialogOption(context, EventType.EXERCISE),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.help, size: ICON_SIZE, color: Colors.blueGrey[300]),
      title: Text('Nothing logged for selected day',
          style: TextStyle(fontSize: PARAGRAPH_FONT_SIZE)),
      onTap: () => _showDialog(context),
      //dense: true,
      trailing:
          /* SizedBox(
      //  height: double.infinity,
        child: */
          Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Add', style: TextStyle(color: Colors.blueGrey[300])),
          Icon(Icons.navigate_next,
              size: SMALL_ICON_SIZE, color: Colors.blueGrey[300]),
        ],
      ),
      //  ),
    );
  }
}

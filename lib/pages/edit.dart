import 'package:flutter/material.dart';
import 'package:xcuseme/model.dart';
import 'package:xcuseme/pages/create_or_edit.dart';
import 'package:xcuseme/constants/style.dart';
import 'package:provider/provider.dart';

class EditPage extends StatelessWidget {
  Future<void> _onSave(BuildContext context, DateTime selectedDay,
      String description, EventType eventType, Event event) async {
    Event newEvent = await Provider.of<Model>(context, listen: false)
        .updateEvent(event, selectedDay, description);

    Navigator.pushNamedAndRemoveUntil(
        context, '/details', (route) => route.isFirst,
        arguments: newEvent);
  }

  Widget _deleteButton(BuildContext context, Event e) {
    return IconButton(
      icon: Icon(Icons.delete, color: Colors.blue[800], size: ICON_SIZE),
      onPressed: () => _showDeleteDialog(context, e),
    );
  }

  Future _showDeleteDialog(BuildContext context, Event e) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Delete? Are you sure?"),
            content: Text('This cannot be undone.'),
            actions: <Widget>[
              TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              TextButton(
                  child: Text('Delete'),
                  onPressed: () async {
                    await Provider.of<Model>(context, listen: false)
                        .deleteEvent(e);
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (_) => false);
                  }),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final Event event = ModalRoute.of(context).settings.arguments;
    return Consumer<Model>(builder: (context, model, child) {
      return CreateOrEditPage(
        eventType: event.type,
        selectedDay: event.datetime,
        events: model.events,
        onSave: _onSave,
        event: event,
        rightButton: _deleteButton(context, event),
      );
    });
  }
}

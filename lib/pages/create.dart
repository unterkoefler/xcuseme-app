import 'package:flutter/material.dart';
import 'package:xcuseme/model.dart';
import 'package:xcuseme/firestore_service.dart';
import 'package:xcuseme/pages/create_or_edit.dart';
import 'package:xcuseme/models/event.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePage extends StatelessWidget {
  final EventType _eventType;

  CreatePage(this._eventType);

  void _onSave(BuildContext context, DateTime selectedDay, String description,
      EventType eventType, Event _) {
    User user = context.read<User>();
    Event event =
        Event(eventType, description, selectedDay.millisecondsSinceEpoch);
    FirestoreService().addEvent(user: user, event: event);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    List<Event> events = context.watch<List<Event>>();
    return Consumer<Model>(builder: (context, model, child) {
      return CreateOrEditPage(
        eventType: _eventType,
        selectedDay: model.selectedDay,
        events: events,
        onSave: _onSave,
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:xcuseme/model.dart';
import 'package:xcuseme/pages/create_or_edit.dart';
import 'package:provider/provider.dart';

class CreatePage extends StatelessWidget {
  final EventType _eventType;

  CreatePage(this._eventType);

  void _onSave(BuildContext context, DateTime selectedDay, String description,
      EventType eventType, Event _) {
    Provider.of<Model>(context, listen: false)
        .addEvent(selectedDay, description, eventType);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      return CreateOrEditPage(
        eventType: _eventType,
        selectedDay: model.selectedDay,
        events: model.events,
        onSave: _onSave,
      );
    });
  }
}

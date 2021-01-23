import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:xcuseme/model.dart';
import 'package:xcuseme/constants/style.dart';
import 'package:xcuseme/constants/constants.dart';
import 'dart:async';

class CreateOrEditPage extends StatefulWidget {
  final EventType eventType;
  final DateTime selectedDay;
  final List<Event> events;
  final Function onSave;
  final Event event; // null if and only if creating
  final Widget rightButton;

  CreateOrEditPage({
    this.eventType,
    this.events,
    this.selectedDay,
    this.onSave,
    this.event,
    this.rightButton,
  });

  @override
  _CreateOrEditPageState createState() => _CreateOrEditPageState(
        eventType: eventType,
        selectedDay: selectedDay,
        events: events,
        onSave: onSave,
        event: event,
        rightButton: rightButton,
      );
}

class _CreateOrEditPageState extends State<CreateOrEditPage> {
  final EventType eventType;
  final List<Event> events;
  final Function onSave;
  final Event event; // null if and only if creating
  final Widget rightButton;
  DateTime selectedDay;
  TextEditingController _controller;

  _CreateOrEditPageState({
    this.eventType,
    this.events,
    this.selectedDay,
    this.onSave,
    this.event,
    this.rightButton,
  });

  void initState() {
    super.initState();
    String text = event?.description ?? '';
    _controller = TextEditingController(text: text);
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDay,
      firstDate: selectedDay.subtract(new Duration(days: 600)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDay) {
      if (_dateIsUnique(picked)) {
        setState(() {
          selectedDay = picked;
        });
      } else {
        await _showNonUniqueDateDialog(context, picked);
      }
    }
  }

  bool _dateIsUnique(DateTime selectedDT) {
    if (this.event != null && isSameDay(selectedDT, this.event.datetime)) {
      // we must be editing an event. It's okay to have an event with the same day as itself
      return true;
    }
    return !this.events.any((event) {
      return isSameDay(event.datetime, selectedDT);
    });
  }

  Future _showNonUniqueDateDialog(
      BuildContext context, DateTime selectedDT) async {
    Event e =
        this.events.firstWhere((ev) => isSameDay(ev.datetime, selectedDT));
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          String date = DateFormat.MMMMEEEEd().format(selectedDT);
          return AlertDialog(
            title: Text("Invalid Date Selected"),
            content: Text(
                'There is already an event logged for $date. Would you like to go edit that one instead?'),
            actions: <Widget>[
              TextButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              TextButton(
                  child: Text('Yes'),
                  onPressed: () => Navigator.popAndPushNamed(context, '/edit',
                      arguments: e)),
            ],
          );
        });
  }

  Widget _buttons(BuildContext context) {
    String type = STRINGS[eventType];
    return Row(children: <Widget>[
      Expanded(
          flex: 3,
          child: ElevatedButton(
              child: Text("Cancel",
                  style: TextStyle(fontSize: SMALL_HEADING_FONT_SIZE)),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.red[500]),
                side: MaterialStateProperty.all<BorderSide>(
                    BorderSide(width: 1, color: Colors.red[500])),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.all(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
              })),
      Spacer(flex: 1),
      Expanded(
          flex: 3,
          child: ElevatedButton(
              child: Text("Save $type",
                  style: TextStyle(fontSize: SMALL_HEADING_FONT_SIZE)),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(TYPE_COLORS[eventType]),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                side: MaterialStateProperty.all<BorderSide>(
                    BorderSide(width: 1, color: Colors.grey[600])),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.all(12)),
              ),
              onPressed: () {
                if (_dateIsUnique(selectedDay)) {
                  this.onSave(
                      context, selectedDay, _controller.text, eventType, event);
                } else {
                  _showNonUniqueDateDialog(context, selectedDay);
                }
              })),
    ]);
  }

  Widget _textField(BuildContext context) {
    return TextField(
        controller: _controller,
        textCapitalization: TextCapitalization.sentences,
        maxLength: 800,
        maxLines: 16,
        minLines: 8,
        decoration: InputDecoration(
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
            labelText: "What's going on?"));
  }

  Widget _datePicker(BuildContext context) {
    String date = DateFormat.MMMMEEEEd().format(selectedDay);
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
        ),
        margin: EdgeInsets.only(right: 18.0, bottom: 18.0, top: 18.0),
        child: Row(
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(left: 12, right: 12),
                child: Text(
                  "$date",
                  style: TextStyle(fontSize: SMALL_HEADING_FONT_SIZE),
                )),
            Ink(
                decoration: BoxDecoration(color: Colors.grey[300]),
                child: IconButton(
                  icon: Icon(Icons.event),
                  tooltip: 'Change Date',
                  onPressed: () => _selectDate(context),
                  color: Colors.black,
                )),
          ],
        ));
  }

  Widget _topRow(BuildContext context) {
    List<Widget> children = [
      _datePicker(context),
      Spacer(flex: 1),
    ];
    if (rightButton != null) {
      children.add(rightButton);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(12.0),
            child: Column(children: <Widget>[
              _topRow(context),
              _textField(context),
              SizedBox(height: 4.0),
              _buttons(context),
            ])));
  }
}

import 'package:flutter/foundation.dart';
import 'package:xcuseme/database.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Model extends ChangeNotifier {
  Map<DateTime, Event> _events;
  final dbHelper = DatabaseHelper.instance;
  final CalendarController calendarController = CalendarController();
  bool loadedData = false;
  MainView mainView = MainView.CALENDAR;
  DateTime selectedDay = DateTime.now();
  Event eventForSelectedDay = null;

  Model(this._events) {
    fetchAndSetData();
  }

  Future<void> fetchAndSetData() async {
    List<Map<String, dynamic>> rows = await dbHelper.queryAllRows();
    Map<DateTime, Event> new_events = Map();
    rows.forEach((row) {
      DateTime dt =
          DateTime.fromMillisecondsSinceEpoch(row[DatabaseHelper.columnMillis]);
      EventType type = row[DatabaseHelper.columnType] == 'EXCUSE'
          ? EventType.EXCUSE
          : EventType.EXERCISE;
      new_events[dt] = Event(type, row[DatabaseHelper.columnDescription]);
    });
    _events = new_events;
    print("loaded data");
    loadedData = true;
    notifyListeners();
  }

  Map<DateTime, Event> get events => _events;

  void addEvent(DateTime when, String description, EventType type) async {
    int millis = when.millisecondsSinceEpoch;
    String type_str = TYPE_STRINGS[type];
    Map<String, dynamic> row = {
      DatabaseHelper.columnMillis: millis,
      DatabaseHelper.columnType: type_str,
      DatabaseHelper.columnDescription: description,
    };
    await dbHelper.insert(row);
    _events[when] = new Event(type, description);
    notifyListeners();
  }

  void toggleMainView() {
      switch (this.mainView) {
          case MainView.CALENDAR:
            this.mainView = MainView.LIST;
            break;
          case MainView.LIST:
            this.mainView = MainView.CALENDAR;
            break;
      }
      notifyListeners();
  }

  void updateSelectedDay(DateTime newDay, Event event) {
    this.selectedDay = newDay;
    this.eventForSelectedDay = event;
    notifyListeners();
  }
}

enum MainView { CALENDAR, LIST }

enum EventType { EXCUSE, EXERCISE }

const Map<EventType, String> TYPE_STRINGS = {
  EventType.EXCUSE: 'EXCUSE',
  EventType.EXERCISE: 'EXERCISE',
};

class Event {
  EventType type;
  String description;

  Event(this.type, this.description);

  @override
  String toString() {
    return "Event(type=${type}, desc=${description})";
  }
}

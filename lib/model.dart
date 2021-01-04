import 'package:flutter/foundation.dart';
import 'package:xcuseme/database.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Model extends ChangeNotifier {
  List<Event> _events;
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
    List<Event> new_events = [];
    rows.forEach((row) {
      int millis = row[DatabaseHelper.columnMillis];
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(millis);
      EventType type = row[DatabaseHelper.columnType] == 'EXCUSE'
          ? EventType.EXCUSE
          : EventType.EXERCISE;
      new_events
          .add(Event(type, row[DatabaseHelper.columnDescription], millis));
    });
    _events = new_events;
    eventForSelectedDay = _events.firstWhere(
        (ev) => isSameDay(ev.datetime, selectedDay),
        orElse: () => null);
    print("loaded data");
    loadedData = true;
    notifyListeners();
  }

  List<Event> get events => _events;

  void addEvent(DateTime when, String description, EventType type) async {
    int millis = when.millisecondsSinceEpoch;
    String type_str = TYPE_STRINGS[type];
    Map<String, dynamic> row = {
      DatabaseHelper.columnMillis: millis,
      DatabaseHelper.columnType: type_str,
      DatabaseHelper.columnDescription: description,
    };
    await dbHelper.insert(row);
    Event event = Event(type, description, millis);
    _events.add(event);
    if (when == selectedDay) {
      eventForSelectedDay = event;
    }
    notifyListeners();
  }

  Future<Event> updateEvent(
      Event oldEvent, DateTime newDate, String newDescription) async {
    if (oldEvent.description == newDescription &&
        oldEvent.datetime == newDate) {
      return oldEvent;
    }
    int oldMillis = oldEvent.millis;
    int newMillis = newDate.millisecondsSinceEpoch;
    String type_str = TYPE_STRINGS[oldEvent.type];
    Map<String, dynamic> newRow = {
      DatabaseHelper.columnMillis: newMillis,
      DatabaseHelper.columnType: type_str,
      DatabaseHelper.columnDescription: newDescription,
    };
    await dbHelper.update(oldMillis, newRow);
    if (oldEvent.datetime != newDate) {
      this.eventForSelectedDay = null;
    }
    oldEvent.description = newDescription;
    oldEvent.millis = newDate.millisecondsSinceEpoch;
    notifyListeners();
    return oldEvent;
  }

  Future<void> deleteEvent(Event event) async {
    _events.remove(event);
    await dbHelper.delete(event.millis);
    if (eventForSelectedDay == event) {
      eventForSelectedDay = null;
    }
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
  int millis;

  Event(this.type, this.description, this.millis);

  DateTime get datetime => DateTime.fromMillisecondsSinceEpoch(millis);

  @override
  String toString() {
    return "Event(type=${type}, desc=${description})";
  }
}

bool isSameDay(DateTime dayA, DateTime dayB) {
  return dayA.year == dayB.year &&
      dayA.month == dayB.month &&
      dayA.day == dayB.day;
}

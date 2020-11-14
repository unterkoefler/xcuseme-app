import 'package:flutter/foundation.dart';
import 'package:xcuseme/database.dart';
import 'package:provider/provider.dart';

class Model extends ChangeNotifier {
  Map<DateTime, Event> _events;
  final dbHelper = DatabaseHelper.instance;

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
    notifyListeners();
  }

  Map<DateTime, Event> get events => _events;

  void addExcuse(DateTime when, String description) async {
    int millis = when.millisecondsSinceEpoch;
    Map<String, dynamic> row = {
      DatabaseHelper.columnMillis: millis,
      DatabaseHelper.columnType: 'EXCUSE',
      DatabaseHelper.columnDescription: description,
    };
    await dbHelper.insert(row);
    _events[when] = new Event(EventType.EXCUSE, description);
    notifyListeners();
  }

  void addExercise(DateTime when, String description) async {
    int millis = when.millisecondsSinceEpoch;
    Map<String, dynamic> row = {
      DatabaseHelper.columnMillis: millis,
      DatabaseHelper.columnType: 'EXERCISE',
      DatabaseHelper.columnDescription: description,
    };
    await dbHelper.insert(row);
    _events[when] = new Event(EventType.EXERCISE, description);
    notifyListeners();
  }
}

enum EventType { EXCUSE, EXERCISE }

class Event {
  EventType type;
  String description;

  Event(this.type, this.description);

  @override
  String toString() {
    return "Event(type=${type}, desc=${description})";
  }
}

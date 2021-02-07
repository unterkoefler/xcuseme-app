import 'package:flutter/foundation.dart';
import 'package:xcuseme/database.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class Model extends ChangeNotifier {
  final dbHelper = DatabaseHelper.instance;
  final CalendarController calendarController = CalendarController();
  MainView mainView = MainView.CALENDAR;
  DateTime selectedDay = DateTime.now();

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

  void updateSelectedDay(DateTime newDay) {
    this.selectedDay = newDay;
    notifyListeners();
  }
}

enum MainView { CALENDAR, LIST }

bool isSameDay(DateTime dayA, DateTime dayB) {
  return dayA.year == dayB.year &&
      dayA.month == dayB.month &&
      dayA.day == dayB.day;
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xcuseme/models/event.dart';
import 'package:xcuseme/model.dart';
import 'dart:math';

class StatsPage extends StatelessWidget {
  int _longestExerciseStreak(List<Event> events) {
    int streak = 0;
    int maxStreak = 0;
    DateTime nextDay = null;
    events.forEach((e) {
      if (nextDay == null || isOneDayAfter(nextDay, e.datetime)) {
        if (e.type == EventType.EXERCISE) {
          streak += 1;
          maxStreak = max(streak, maxStreak);
          nextDay = e.datetime;
        } else {
          streak = 0;
          nextDay = e.datetime;
        }
      } else {
        streak = 0;
        nextDay = null;
      }
    });
    return maxStreak;
  }

  @override
  Widget build(BuildContext context) {
    List<Event> events = context.watch<List<Event>>();
    events.sort((a, b) => b.millis.compareTo(a.millis));
    int excuseCount = events.where((e) => e.type == EventType.EXCUSE).length;
    int exerciseCount =
        events.where((e) => e.type == EventType.EXERCISE).length;
    int longestExerciseStreak = _longestExerciseStreak(events);
    return Column(
      children: <Widget>[
        Text('Number of excuses: $excuseCount'),
        Text('Number of exercises: $exerciseCount'),
        Text('Longest exercise streak: $longestExerciseStreak'),
      ],
    );
  }
}

// is d1 one day after d2?
bool isOneDayAfter(DateTime d1, DateTime d2) {
  return isSameDay(d1.subtract(Duration(days: 1)), d2);
}

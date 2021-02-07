import 'package:flutter/material.dart';
import 'package:xcuseme/models/event.dart';

const Map<EventType, String> PATHS = {
  EventType.EXCUSE: '/log-excuse',
  EventType.EXERCISE: '/log-exercise'
};
const Map<EventType, String> BUTTON_LABELS = {
  EventType.EXCUSE: 'Log Excuse',
  EventType.EXERCISE: 'Log Exercise'
};
const Map<EventType, Color> TYPE_COLORS = {
  EventType.EXCUSE: Color(0xffef9a9a), // Colors.red[200]
  EventType.EXERCISE: Color(0xff80cbc4) // Colors.teal[200]
};
const Map<EventType, IconData> TYPE_ICONS = {
  EventType.EXCUSE: Icons.hotel,
  EventType.EXERCISE: Icons.directions_run,
};
const Map<EventType, String> STRINGS = {
  EventType.EXCUSE: 'Excuse',
  EventType.EXERCISE: 'Exercise',
};

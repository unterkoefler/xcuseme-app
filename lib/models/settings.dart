import 'package:flutter/material.dart';

class UserSettings {
  final bool hasReminderOn;
  final TimeOfDay reminderTime;

  static final hasReminderOnKey = 'has_reminder_on';
  static final reminderTimeHourKey = 'reminder_time_hour';
  static final reminderTimeMinuteKey = 'reminder_time_minute';

  static final defaultHour = 20;
  static final defaultMinute = 0;
  static final defaultHasReminderOn = false;

  UserSettings(this.hasReminderOn, this.reminderTime);

  factory UserSettings.fromMap(Map<String, dynamic> data) {
    TimeOfDay _reminderTime = TimeOfDay(
      hour: data[reminderTimeHourKey] ?? defaultHour,
      minute: data[reminderTimeMinuteKey] ?? defaultMinute,
    );
    return UserSettings(
        data[hasReminderOnKey] ?? defaultHasReminderOn, _reminderTime);
  }

  Map<String, dynamic> toMap() {
    return {
      hasReminderOnKey: hasReminderOn,
      reminderTimeHourKey: reminderTime.hour,
      reminderTimeMinuteKey: reminderTime.minute,
    };
  }
}

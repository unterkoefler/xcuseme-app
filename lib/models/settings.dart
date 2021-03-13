import 'package:flutter/material.dart';

class UserSettings {
  final bool hasReminderOn;
  final TimeOfDay reminderTime;

  static final hasReminderOnKey = 'has_reminder_on';
  static final reminderTimeHourKey = 'reminder_time_hour';
  static final reminderTimeMinuteKey = 'reminder_time_minute';

  static final defaultReminderTime = TimeOfDay(hour: 20, minute: 0);
  static final defaultHasReminderOn = false;

  UserSettings(this.hasReminderOn, this.reminderTime);

  // assumes times are given in UTC and converts to local timezones
  factory UserSettings.fromMapAndLocalize(Map<String, dynamic> data) {
    TimeOfDay _reminderTime;
    if (data.containsKey(reminderTimeHourKey) &&
        data.containsKey(reminderTimeMinuteKey)) {
      TimeOfDay _reminderTimeUtc = TimeOfDay(
          hour: data[reminderTimeHourKey], minute: data[reminderTimeMinuteKey]);
      _reminderTime = _localize(_reminderTimeUtc);
    } else {
      _reminderTime = defaultReminderTime;
    }

    return UserSettings(
        data[hasReminderOnKey] ?? defaultHasReminderOn, _reminderTime);
  }

  Map<String, dynamic> toMapAndStandardize() {
    TimeOfDay todUtc = _toUtc(reminderTime);
    return {
      hasReminderOnKey: hasReminderOn,
      reminderTimeHourKey: todUtc.hour,
      reminderTimeMinuteKey: todUtc.minute,
    };
  }

  static TimeOfDay _localize(TimeOfDay todUtc) {
    DateTime now = DateTime.now();
    DateTime dtUtc =
        DateTime.utc(now.year, now.month, now.day, todUtc.hour, todUtc.minute);
    DateTime dtLocal = dtUtc.toLocal();
    return TimeOfDay.fromDateTime(dtLocal);
  }

  static TimeOfDay _toUtc(TimeOfDay todLocal) {
    DateTime now = DateTime.now();
    DateTime dtLocal =
        DateTime(now.year, now.month, now.day, todLocal.hour, todLocal.minute);
    DateTime dtUtc = dtLocal.toUtc();
    return TimeOfDay.fromDateTime(dtUtc);
  }
}

import 'package:flutter/material.dart';
import 'package:xcuseme/constants/style.dart';
import 'package:xcuseme/constants/constants.dart';
import 'package:xcuseme/models/event.dart';
import 'package:xcuseme/models/settings.dart';
import 'package:xcuseme/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:time_picker_widget/time_picker_widget.dart';

class SettingsStreamProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserSettings>(
      create: (context) =>
          FirestoreService().settingsStream(user: context.read<User>()),
      initialData: null,
      child: SettingsPage(),
    );
  }
}

class SettingsPage extends StatelessWidget {
  _onToggleReminder(
      BuildContext context, UserSettings currentSettings, bool val) async {
    if (val) {
      NotificationSettings notificationSettings =
          await FirebaseMessaging.instance.requestPermission();
      if (notificationSettings.authorizationStatus !=
          AuthorizationStatus.authorized) {
        return;
      }
      String token = await FirebaseMessaging.instance.getToken();
      await FirestoreService().updateTokens(token);
    }
    UserSettings newSettings = UserSettings(val, currentSettings.reminderTime);
    FirestoreService()
        .updateSettings(user: context.read<User>(), settings: newSettings);
  }

  _onChangeReminderTime(
      BuildContext context, UserSettings currentSettings) async {
    TimeOfDay initialTime = currentSettings.reminderTime;
    TimeOfDay newTime = await showCustomTimePicker(
      context: context,
      initialTime: initialTime,
      onFailValidation: (_) {},
      selectableTimePredicate: (time) => time.minute % 30 == 0,
    );
    if (newTime == null) {
      return;
    }
    UserSettings newSettings =
        UserSettings(currentSettings.hasReminderOn, newTime);
    FirestoreService()
        .updateSettings(user: context.read<User>(), settings: newSettings);
  }

  _maybeTimeSelector(BuildContext context, UserSettings settings) {
    if (!settings.hasReminderOn) {
      return Container();
    }
    String timeString = settings.reminderTime.format(context);
    return Container(
        padding: EdgeInsets.all(18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Send me a reminder at:'),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text(timeString),
                  ),
                  Ink(
                    decoration: BoxDecoration(color: Colors.grey[300]),
                    child: IconButton(
                      icon: Icon(Icons.schedule),
                      tooltip: 'Change reminder time',
                      onPressed: () => _onChangeReminderTime(context, settings),
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    UserSettings settings = context.watch<UserSettings>();

    if (settings == null) {
      return Text('Loading...');
    }

    final String title = 'Settings';
    final Color color = TYPE_COLORS[EventType.EXCUSE];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(18),
          child: Text(title,
              style: TextStyle(color: color, fontSize: HEADING_FONT_SIZE)),
        ),
        ListTile(
          title: Text('Daily Reminder'),
          trailing: Switch(
            value: settings.hasReminderOn,
            onChanged: (bool val) => _onToggleReminder(context, settings, val),
            activeColor: Colors.teal[300],
            activeTrackColor: Colors.teal[200],
          ),
          leading: Icon(Icons.notifications),
        ),
        _maybeTimeSelector(context, settings),
      ],
    );
  }
}

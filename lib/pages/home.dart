import 'package:flutter/material.dart';
import 'package:xcuseme/constants/style.dart';
import 'package:xcuseme/constants/constants.dart';
import 'package:xcuseme/widgets/xcuse_list.dart';
import 'package:xcuseme/widgets/xcuse_calendar.dart';
import 'package:xcuseme/model.dart';
import 'package:xcuseme/models/event.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final Model model;

  HomePage(this.model);

  bool _shouldDisableLogButtons(BuildContext context) {
    List<Event> events = context.watch<List<Event>>();
    return events.any((event) {
      return isSameDay(event.datetime, model.selectedDay);
    });
  }

  Widget _logButton(BuildContext context, EventType type) {
    String next = PATHS[type];
    String label = BUTTON_LABELS[type];

    Color getColor(Set<MaterialState> states) {
      if (states.contains(MaterialState.disabled)) {
        return Colors.grey[400];
      }
      return TYPE_COLORS[type];
    }

    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 14.0, left: 12.0, right: 12.0),
        child: ElevatedButton(
            style: ButtonStyle(
                padding: MaterialStateProperty.all(
                    EdgeInsets.all(SMALL_HEADING_FONT_SIZE)),
                backgroundColor: MaterialStateProperty.resolveWith(getColor),
                foregroundColor: MaterialStateProperty.all(Colors.white)),
            child: Text(label,
                style: TextStyle(fontSize: SMALL_HEADING_FONT_SIZE)),
            onPressed: _shouldDisableLogButtons(context)
                ? null
                : () {
                    Navigator.pushNamed(
                      context,
                      next,
                    );
                  }));
  }

  Widget _getView(BuildContext context) {
    switch (model.mainView) {
      case MainView.CALENDAR:
        return XCuseCalendar(model);
      case MainView.LIST:
        return XCuseList(model);
    }
  }

  final Map<MainView, IconData> icons = {
    MainView.CALENDAR: Icons.view_list,
    MainView.LIST: Icons.date_range,
  };

  final Map<MainView, String> labels = {
    MainView.CALENDAR: "Switch to list view",
    MainView.LIST: "Switch to calendar view",
  };

  Widget _changeViewButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 12.0),
      child: Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: Icon(
              icons[model.mainView],
              color: Colors.blueGrey[300],
              size: ICON_SIZE,
              semanticLabel: labels[model.mainView],
            ),
            onPressed: () => model.toggleMainView(),
          )),
    );
  }

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _logButton(context, EventType.EXCUSE),
        _logButton(context, EventType.EXERCISE),
        _changeViewButton(context),
        _getView(context),
      ],
    );
  }
}

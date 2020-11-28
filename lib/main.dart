import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:xcuseme/model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

void main() async {
  runApp(
    ChangeNotifierProvider<Model>(
      create: (context) => Model({}),
      child: XCuseMeApp(),
    ),
  );
}

class XCuseMeApp extends StatelessWidget {
  Widget _infoAction() {
    return Container(
        margin: EdgeInsets.only(right: 12.0),
        child: Icon(
          Icons.info,
          color: Colors.blueGrey[300],
          size: 36.0,
          semanticLabel: 'About this app',
        ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XCuseMe',
      initialRoute: '/',
      routes: {
        '/': (context) => XCuseMeScaffold(HomePage(), actions: [_infoAction()]),
        '/log-excuse': (context) =>
            XCuseMeScaffold(CreatePageContainer(EventType.EXCUSE)),
        '/log-exercise': (context) =>
            XCuseMeScaffold(CreatePageContainer(EventType.EXERCISE)),
      },
    );
  }
}

class XCuseMeScaffold extends StatelessWidget {
  Widget body;
  List<Widget> actions;

  XCuseMeScaffold(this.body, {List<Widget> actions = const []}) {
    this.actions = actions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('XCuseMe',
                style: TextStyle(color: Colors.deepPurple[500])),
            centerTitle: true,
            actions: actions,
            flexibleSpace: Container(
                decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal[200], Colors.red[200]],
              ),
            ))),
        body: this.body);
  }
}

final Map<EventType, String> PATHS = {
  EventType.EXCUSE: '/log-excuse',
  EventType.EXERCISE: '/log-exercise'
};
final Map<EventType, String> BUTTON_LABELS = {
  EventType.EXCUSE: 'Log Excuse',
  EventType.EXERCISE: 'Log Exercise'
};
final Map<EventType, Color> TYPE_COLORS = {
  EventType.EXCUSE: Colors.red[200],
  EventType.EXERCISE: Colors.teal[200]
};
final Map<EventType, String> STRINGS = {
  EventType.EXCUSE: 'Excuse',
  EventType.EXERCISE: 'Exercise',
};

class HomePage extends StatelessWidget {
  Widget _logButton(BuildContext context, EventType type) {
    String next = PATHS[type];
    String label = BUTTON_LABELS[type];
    Color color = TYPE_COLORS[type];

    return Container(
        width: double.infinity,
        margin: EdgeInsets.all(12.0),
        child: ElevatedButton(
            style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.all(18.0)),
                backgroundColor: MaterialStateProperty.all(color)),
            child: Text(label, textScaleFactor: 2),
            onPressed: () {
              Navigator.pushNamed(
                context,
                next,
              );
            }));
  }

  Widget _changeViewButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 12.0, top: 24.0),
      child: Align(
          alignment: Alignment.centerRight,
          child: Icon(
            Icons.view_list,
            color: Colors.blueGrey[300],
            size: 42.0,
            semanticLabel: 'Switch to list view',
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        _logButton(context, EventType.EXCUSE),
        _logButton(context, EventType.EXERCISE),
        _changeViewButton(context),
        Consumer<Model>(builder: (context, model, child) {
          return XCuseCalendar(model);
        }),
      ],
    ));
  }
}

class XCuseCalendar extends StatelessWidget {
  final Map<DateTime, List<Event>> _events_for_cal = Map();
  CalendarController _calendarController;

  XCuseCalendar(model) {
    this._calendarController = model.calendarController;
    model.events.forEach((dt, event) {
      _events_for_cal[dt] = [event];
    });
  }

  Widget _buildEventMarker(DateTime dt, Event event) {
    Color color = TYPE_COLORS[event.type];
    return SizedBox.expand(
      child: Container(
        margin: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withAlpha(80),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      calendarController: _calendarController,
      endDay: DateTime.now(),
      events: _events_for_cal,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.blue[800],
        todayColor: Colors.blue[200],
      ),
      availableCalendarFormats: const {
        CalendarFormat.month: '',
      },
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        decoration: BoxDecoration(
          color: Colors.amber[100],
        ),
        headerMargin: EdgeInsets.only(bottom: 24.0),
        headerPadding: EdgeInsets.symmetric(vertical: 0.0),
      ),
      builders:
          CalendarBuilders(markersBuilder: (context, date, events, holidays) {
        if (events.isNotEmpty &&
            !_calendarController.isSelected(date) &&
            !_calendarController.isToday(date)) {
          return <Widget>[_buildEventMarker(date, events[0])];
        } else {
          return <Widget>[];
        }
      }),
    );
  }
}

class CreatePageContainer extends StatelessWidget {
  final EventType _eventType;

  CreatePageContainer(this._eventType);

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      return CreatePage(_eventType, model.calendarController.selectedDay);
    });
  }
}

class CreatePage extends StatefulWidget {
  final EventType _eventType;
  final DateTime _selectedDay;

  CreatePage(this._eventType, this._selectedDay);

  @override
  _CreatePageState createState() => _CreatePageState(_eventType, _selectedDay);
}

class _CreatePageState extends State<CreatePage> {
  DateTime selectedDate;
  final EventType _eventType;
  TextEditingController _controller;

  _CreatePageState(this._eventType, this.selectedDate);

  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: selectedDate.subtract(new Duration(days: 600)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget _buttons(BuildContext context) {
    String type = STRINGS[_eventType];
    return Row(children: <Widget>[
      Expanded(
          flex: 3,
          child: ElevatedButton(
              child: Text("Cancel", style: TextStyle(fontSize: 18)),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.red[500]),
                side: MaterialStateProperty.all<BorderSide>(
                    BorderSide(width: 1, color: Colors.red[500])),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.all(16)),
              ),
              onPressed: () {
                Navigator.pop(context);
              })),
      Spacer(flex: 1),
      Expanded(
          flex: 3,
          child: ElevatedButton(
              child: Text("Save ${type}", style: TextStyle(fontSize: 18)),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(TYPE_COLORS[_eventType]),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                side: MaterialStateProperty.all<BorderSide>(
                    BorderSide(width: 1, color: Colors.black)),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.all(16)),
              ),
              onPressed: () {
                Provider.of<Model>(context, listen: false)
                    .addEvent(selectedDate, _controller.text, _eventType);
                Navigator.pop(context);
              })),
    ]);
  }

  Widget _textField(BuildContext context) {
    return TextField(
        controller: _controller,
        textCapitalization: TextCapitalization.sentences,
        maxLength: 800,
        maxLines: 16,
        minLines: 8,
        decoration: InputDecoration(
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
            labelText: "What's going on?"));
  }

  Widget _datePicker(BuildContext context) {
    String date = DateFormat.MMMMEEEEd().format(selectedDate);
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
        ),
        margin: EdgeInsets.only(right: 96.0, bottom: 18.0, top: 18.0),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Container(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      "${date}",
                      style: TextStyle(fontSize: 18),
                    ))),
            Ink(
                decoration: BoxDecoration(color: Colors.grey[300]),
                child: IconButton(
                  icon: Icon(Icons.event),
                  tooltip: 'Change Date',
                  onPressed: () => _selectDate(context),
                  color: Colors.black,
                )),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(12.0),
            child: Column(children: <Widget>[
              _datePicker(context),
              _textField(context),
              _buttons(context),
            ])));
  }
}

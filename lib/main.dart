import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:xcuseme/model.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(
    ChangeNotifierProvider<Model>(
      create: (context) => Model({}),
      child: XCuseMeApp(),
    ),
  );
}

class XCuseMeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XCuseMe',
      initialRoute: '/',
      routes: {
        '/': (context) => XCuseMeScaffold(HomePage()),
        '/log-excuse': (context) => XCuseMeScaffold(LogExcusePage()),
        '/log-exercise': (context) => XCuseMeScaffold(LogExercisePage()),
      },
    );
  }
}

class XCuseMeScaffold extends StatelessWidget {
  Widget body;
  XCuseMeScaffold(this.body);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('XCuseMe')), body: this.body);
  }
}

final Map<EventType, String> PATHS = {
  EventType.EXCUSE: '/log-excuse',
  EventType.EXERCISE: '/log-exercise'
};
final Map<EventType, String> LABELS = {
  EventType.EXCUSE: 'Log Excuse',
  EventType.EXERCISE: 'Log Exercise'
};
final Map<EventType, Color> TYPE_COLORS = {
  EventType.EXCUSE: Colors.red,
  EventType.EXERCISE: Colors.green
};

class HomePage extends StatelessWidget {
  final CalendarController _calendarController = CalendarController();

  Widget _logButton(BuildContext context, EventType type) {
    String next = PATHS[type];
    String label = LABELS[type];
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        _logButton(context, EventType.EXCUSE),
        _logButton(context, EventType.EXERCISE),
        Consumer<Model>(builder: (context, model, child) {
          return XCuseCalendar(model, _calendarController);
        }),
      ],
    ));
  }
}

class XCuseCalendar extends StatelessWidget {
  final Map<DateTime, List<Event>> _events_for_cal = Map();
  final CalendarController _calendarController;

  XCuseCalendar(model, this._calendarController) {
    model.events.forEach((dt, event) {
      _events_for_cal[dt] = [event];
    });
  }

  Widget _buildEventMarker(DateTime dt, Event event) {
    Color color = TYPE_COLORS[event.type];
    return SizedBox.expand(
      child: Container(
        margin: const EdgeInsets.all(12.0),
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
      events: _events_for_cal,
      calendarStyle: CalendarStyle(
        markersColor: Colors.deepOrange[400],
      ),
      builders:
          CalendarBuilders(markersBuilder: (context, date, events, holidays) {
        if (events.isNotEmpty) {
          return <Widget>[_buildEventMarker(date, events[0])];
        } else {
          return <Widget>[];
        }
      }),
    );
  }
}

class LogExcusePage extends StatefulWidget {
  @override
  _LogExcuseState createState() => _LogExcuseState();
}

class _LogExcuseState extends State<LogExcusePage> {
  DateTime selectedDate = DateTime.now();
  TextEditingController _controller;

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
      firstDate: selectedDate.subtract(new Duration(days: 30)),
      lastDate: selectedDate,
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String date = "${selectedDate.toLocal()}".split(' ')[0];
    return Container(
        padding: EdgeInsets.all(12.0),
        child: Column(children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                "Log an excuse for: ${date}",
                style: TextStyle(fontSize: 14),
              ),
              FlatButton(
                onPressed: () => _selectDate(context),
                child: Text('Change Date'),
              )
            ],
          ),
          TextField(
              controller: _controller,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: "What's going on?")),
          ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                Provider.of<Model>(context, listen: false)
                    .addExcuse(selectedDate, _controller.text);
                Navigator.pop(context);
              }),
        ]));
  }
}

class LogExercisePage extends StatefulWidget {
  @override
  _LogExerciseState createState() => _LogExerciseState();
}

class _LogExerciseState extends State<LogExercisePage> {
  DateTime selectedDate = DateTime.now();
  TextEditingController _controller;

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
      firstDate: selectedDate.subtract(new Duration(days: 30)),
      lastDate: selectedDate,
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String date = "${selectedDate.toLocal()}".split(' ')[0];
    return Container(
        padding: EdgeInsets.all(12.0),
        child: Column(children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                "Log an exercise for: ${date}",
                style: TextStyle(fontSize: 14),
              ),
              FlatButton(
                onPressed: () => _selectDate(context),
                child: Text('Change Date'),
              )
            ],
          ),
          TextField(
              controller: _controller,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: "What did you do?")),
          ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                Provider.of<Model>(context, listen: false)
                    .addExercise(selectedDate, _controller.text);
                Navigator.pop(context);
              }),
        ]));
  }
}

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

class HomePage extends StatelessWidget {
  final CalendarController _calendarController = CalendarController();

  Widget _logButton(BuildContext context, String label) {
    String next = label == 'Log Excuse' ? '/log-excuse' : '/log-exercise';
    return Container(
        width: double.infinity,
        margin: EdgeInsets.all(12.0),
        child: ElevatedButton(
            style: ButtonStyle(
                padding: MaterialStateProperty.all(EdgeInsets.all(18.0))),
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
        _logButton(context, 'Log Excuse'),
        _logButton(context, 'Log Exercise'),
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

  @override
  Widget build(BuildContext context) {
    print(_events_for_cal);
    return TableCalendar(
      calendarController: _calendarController,
      events: _events_for_cal,
      calendarStyle: CalendarStyle(
        markersColor: Colors.deepOrange[400],
      ),
    );
  }
}

class LogExcusePage extends StatefulWidget {
  //Function addExcuse;

  // LogExcusePage(this.addExcuse);

  @override
  _LogExcuseState createState() => _LogExcuseState(/*addExcuse*/);
}

class _LogExcuseState extends State<LogExcusePage> {
  DateTime selectedDate = DateTime.now();
  TextEditingController _controller;
  //Function addExcuse;

  //_LogExcuseState(this.addExcuse);

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
  //Function addExercise;

  //LogExercisePage(this.addExercise);

  @override
  _LogExerciseState createState() => _LogExerciseState(/*addExercise*/);
}

class _LogExerciseState extends State<LogExercisePage> {
  DateTime selectedDate = DateTime.now();
  TextEditingController _controller;
  // Function addExercise;

  //_LogExerciseState(this.addExercise);

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

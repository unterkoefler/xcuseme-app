import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(XCuseMeApp());
}

class XCuseMeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XCuseMe',
      initialRoute: '/',
      routes: {
        '/': (context) => XCuseMeScaffold(HomePage()),
        '/log': (context) => XCuseMeScaffold(LogExcusePage()),
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
  Widget _logButton(BuildContext context, String label) {
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
                '/log',
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
        XCuseCalendar(),
      ],
    )
    );
  }
}

class XCuseCalendar extends StatefulWidget {
  @override
  _XCuseCalendarState createState() => _XCuseCalendarState();
}

class _XCuseCalendarState extends State<XCuseCalendar> {
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      calendarController: _calendarController,
    );
  }
}

class LogExcusePage extends StatefulWidget {
  @override
  _LogExcuseState createState() => _LogExcuseState();
}

class _LogExcuseState extends State<LogExcusePage> {
  DateTime selectedDate = DateTime.now();

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
    return Row(
      children: <Widget>[
        Text(
          "${selectedDate.toLocal()}".split(' ')[0],
          style: TextStyle(fontSize: 35),
        ),
        RaisedButton(
          onPressed: () => _selectDate(context),
          child: Text('Select date'),
        )
      ],
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:xcuseme/model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider<Model>(
      create: (context) => Model([]),
      child: XCuseMeApp(),
    ),
  );
}

class InfoAction extends StatelessWidget {
  final bool selected;

  InfoAction({this.selected});

  Widget build(BuildContext context) {
    Color color = selected ? Colors.blue[800] : Colors.blueGrey[300];
    return Container(
        margin: EdgeInsets.only(right: 12.0),
        child: IconButton(
          icon: Icon(
            Icons.info,
            color: color,
            size: 36.0,
            semanticLabel: 'About this app',
          ),
          onPressed: () => selected
              ? Navigator.pop(context)
              : Navigator.pushNamed(context, '/info'),
        ));
  }
}

class XCuseMeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XCuseMe',
      initialRoute: '/loading',
      routes: {
        '/': (context) =>
            XCuseMeScaffold(HomePage(), actions: [InfoAction(selected: false)]),
        '/log-excuse': (context) =>
            XCuseMeScaffold(CreatePageContainer(EventType.EXCUSE)),
        '/log-exercise': (context) =>
            XCuseMeScaffold(CreatePageContainer(EventType.EXERCISE)),
        '/info': (context) =>
            XCuseMeScaffold(InfoPage(), actions: [InfoAction(selected: true)]),
        '/loading': (context) => Material(child: MaybeLoadingPage()),
        '/details': (context) => XCuseMeScaffold(DetailsPage()),
        '/edit': (context) => XCuseMeScaffold(EditPageContainer()),
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
final Map<EventType, IconData> TYPE_ICONS = {
  EventType.EXCUSE: Icons.hotel,
  EventType.EXERCISE: Icons.directions_run,
};
final Map<EventType, String> STRINGS = {
  EventType.EXCUSE: 'Excuse',
  EventType.EXERCISE: 'Exercise',
};

class MaybeLoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      if (model.loadedData) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Timer(Duration(seconds: 2), () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
          });
        });
      }
      return LoadingPage();
    });
  }
}

class LoadingPage extends StatelessWidget {
  Widget _loadingIndicator(BuildContext context) {
    return LinearProgressIndicator(
        value: null,
        backgroundColor: Colors.teal[300],
        valueColor: AlwaysStoppedAnimation<Color>(Colors.red[300]),
        minHeight: 14);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
        child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [Colors.teal[200], Colors.red[200]],
            )),
            child: Column(children: <Widget>[
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('XCuseMe',
                      style: TextStyle(
                          fontSize: 48, color: Colors.deepPurple[500])),
                  Text('The exercise tracking app for real people',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                          color: Colors.black)),
                ],
              )),
              _loadingIndicator(context)
            ])));
  }
}

class DetailsPage extends StatelessWidget {
  Widget _editButton(BuildContext context, Event e) {
    return IconButton(
      icon: Icon(Icons.edit, color: Colors.blue[800], size: 36),
      onPressed: () => Navigator.pushNamed(context, '/edit', arguments: e),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Event event = ModalRoute.of(context).settings.arguments;
    final DateTime dt = event.datetime;;
    final String title = '${STRINGS[event.type]} Details';
    final Color color = TYPE_COLORS[event.type];
    String date = DateFormat.MMMMEEEEd().format(dt);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(title, style: TextStyle(color: color, fontSize: 36)),
                _editButton(context, event),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 24, right: 24, bottom: 12),
            child: Text(date, style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18)),
          ),
          Container(
            padding: EdgeInsets.only(left: 24, right: 24, top: 12),
            child: Text(event.description, style: TextStyle(fontSize: 16)),
          ),
      ],
    );
  }
}

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const info_pre = """
XCuseMe is the exercise tracking app for real people. Use it to track your exercise -- and your excuses! Ever wonder how many times you've skipped your ab routine because you woke up too late? Or exactly how long that knee injury kept you on the couch? Life happens and sometimes we can't keep up, but now we can keep track.

To record a new activity, tap the "Log Excuse" or "Log Exercise" button, enter a text description of your exercise or excuse, and press "Save". Only one type of activity can be saved on a given day. If you went for a run yesterday, but skipped your core workout, you can note that in the description of your exercise and be proud that you did anything!

To ensure your privacy, all data is stored locally on your device and will never be sold to third-parties.

XCuseMe is currently in active development. To report a bug or request a feature, please create an issue on """;

    const info_post = """.

Thank you and have a good day!
    """;
    return SizedBox.expand(
        child: Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.grey[200]),
      child: RichText(
          text: TextSpan(
        text: info_pre,
        style: TextStyle(color: Colors.black, fontSize: 18, height: 1.5),
        children: <TextSpan>[
          TextSpan(
            text: 'the Github repository',
            style: TextStyle(
                color: Colors.blue[800], decoration: TextDecoration.underline),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launch('https://github.com/unterkoefler/xcuseme');
              },
          ),
          TextSpan(text: info_post),
        ],
      )),
    ));
  }
}

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Column(
      children: <Widget>[
        _logButton(context, EventType.EXCUSE),
        _logButton(context, EventType.EXERCISE),
        Consumer<Model>(builder: (context, model, child) {
          return HomePageMainView(model);
        }),
      ],
    ));
  }
}

class HomePageMainView extends StatelessWidget {
  final Model model;

  HomePageMainView(this.model);

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
      margin: EdgeInsets.only(right: 12.0, top: 6.0, bottom: 6),
      child: Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: Icon(
              icons[model.mainView],
              color: Colors.blueGrey[300],
              size: 42.0,
              semanticLabel: labels[model.mainView],
            ),
            onPressed: () => model.toggleMainView(),
          )
        ),
    );
  }


  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _changeViewButton(context),
        _getView(context),
      ],
    );
  }
}

class XCuseList extends StatelessWidget {
  final Model model;

  XCuseList(this.model);

  Widget build(BuildContext context) {
    List<Event> events = model.events;
    events.sort((a, b) => b.millis.compareTo(a.millis));

    return SizedBox(
      height: 500, // TODO: make relative to device
      child: ListView.separated(
      itemCount: events.length,
      itemBuilder: (BuildContext context, int index) {
        Event e = events.elementAt(index);
        return EventTile(e);
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    ));
  }
}

class EventTile extends StatelessWidget {
  final Event event;

  EventTile(this.event);

  Icon _icon(BuildContext context) {
    Color color = TYPE_COLORS[event.type];
    IconData iconData = TYPE_ICONS[event.type];
    return Icon(
      iconData,
      size: 36.0,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    String date = DateFormat.Md().format(event.datetime);
    String title = "${date} - ${event.description}";
    return ListTile(
      onTap: () => Navigator.pushNamed(context, '/details', arguments: event),
      leading: _icon(context),
      title: Text(title, softWrap: false, overflow: TextOverflow.ellipsis,),
      trailing: SizedBox(
            height: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Details", style: TextStyle(color: Colors.blueGrey[300])),
                Icon(Icons.navigate_next, size: 24, color: Colors.blueGrey[300]),
              ],
            )
          ),
    );
  }
}

class CreateEventTile extends StatelessWidget {
  Widget _dialogOption(BuildContext context, EventType type) {
    String next = PATHS[type];
    String label = BUTTON_LABELS[type];
    Color color = TYPE_COLORS[type];

    return SimpleDialogOption(
      onPressed: () { Navigator.pushReplacementNamed(context, next); },
      child: Text(label, style: TextStyle(fontSize: 24, color: color)),
    );
  }

  Future _showDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            _dialogOption(context, EventType.EXCUSE),
            const Divider(),
            _dialogOption(context, EventType.EXERCISE),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.help, size: 36.0, color: Colors.blueGrey[300]),
      title: Text('Nothing logged for selected day'),
      onTap: () => _showDialog(context),
      trailing: SizedBox(
          height: double.infinity,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Add', style: TextStyle(color: Colors.blueGrey[300])),
              Icon(Icons.navigate_next, size: 24, color: Colors.blueGrey[300]),
            ],
          ),
      ),
    );
  }
}

class XCuseCalendar extends StatelessWidget {
  final Map<DateTime, List<Event>> _events_for_cal = Map();
  CalendarController _calendarController;
  Model model;

  XCuseCalendar(model) {
    this.model = model;
    this._calendarController = model.calendarController;
    model.events.forEach((event) {
      _events_for_cal[event.datetime] = [event];
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

  Widget _calendar(BuildContext context) {
    return TableCalendar(
      calendarController: _calendarController,
      endDay: DateTime.now(),
      events: _events_for_cal,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.blue[800],
        todayColor: Colors.blue[200],
      ),
      onDaySelected: _onDaySelected,
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

  Widget _eventForSelectedDay(BuildContext context) {
    Event event = model.eventForSelectedDay;
    if (event == null) {
      return CreateEventTile();
    } else {
      return EventTile(event);
    }
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    Event event = events.isEmpty ? null : events[0];
    model.updateSelectedDay(day, event);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _calendar(context),
        const Divider(),
        _eventForSelectedDay(context),
        const Divider()
      ],
    );
  }
}

class EditPageContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Event event = ModalRoute.of(context).settings.arguments;
    return EditPage(event);
  }
}

class EditPage extends StatefulWidget {
  final Event event;

  EditPage(this.event);

  @override
  _EditPageState createState() => _EditPageState(event);
}

class _EditPageState extends State<EditPage> {
  DateTime selectedDate;
  final Event event;
  TextEditingController _controller;

  _EditPageState(this.event) {
    this.selectedDate = this.event.datetime;
  }

  void initState() {
    super.initState();
    _controller = TextEditingController(text: event.description);
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
    String type = STRINGS[event.type];
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
                    MaterialStateProperty.all<Color>(TYPE_COLORS[event.type]),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                side: MaterialStateProperty.all<BorderSide>(
                    BorderSide(width: 1, color: Colors.black)),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.all(16)),
              ),
              onPressed: () async {
                Event newEvent = await Provider.of<Model>(context, listen: false)
                    .updateEvent(event, selectedDate, _controller.text);

                Navigator.pushNamedAndRemoveUntil(context, '/details', (route) => route.isFirst, arguments: newEvent);
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


class CreatePageContainer extends StatelessWidget {
  final EventType _eventType;

  CreatePageContainer(this._eventType);

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      return CreatePage(_eventType, model.selectedDay);
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

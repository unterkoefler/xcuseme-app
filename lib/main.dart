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
      initialSelectedDay: model.selectedDay ?? DateTime.now(),
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

  Future<void> _onSave(BuildContext context, DateTime selectedDay, String description, EventType eventType, Event event)  async {
    Event newEvent = await Provider.of<Model>(context, listen: false)
      .updateEvent(event, selectedDay, description);

    Navigator.pushNamedAndRemoveUntil(context, '/details', (route) => route.isFirst, arguments: newEvent);
  }

  Widget _deleteButton(BuildContext context, Event e) {
    return IconButton(
      icon: Icon(Icons.delete, color: Colors.blue[800], size: 36),
      onPressed: () => _showDeleteDialog(context, e),
    );
  }

  Future _showDeleteDialog(BuildContext context, Event e) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete? Are you sure?"),
          content: Text('This cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              }
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                await Provider.of<Model>(context, listen: false)
                    .deleteEvent(e);
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              }
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final Event event = ModalRoute.of(context).settings.arguments;
    return Consumer<Model>(builder: (context, model, child) {
      return CreateOrEditPage(
        eventType: event.type,
        selectedDay: event.datetime,
        events: model.events,
        onSave: _onSave,
        event: event,
        rightButton: _deleteButton(context, event),
      );
    });
  }
}

class CreatePageContainer extends StatelessWidget {
  final EventType _eventType;

  CreatePageContainer(this._eventType);

  void _onSave(BuildContext context, DateTime selectedDay, String description, EventType eventType, Event _) {
    Provider.of<Model>(context, listen: false)
      .addEvent(selectedDay, description, eventType);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      return CreateOrEditPage(
        eventType: _eventType,
        selectedDay: model.selectedDay,
        events: model.events,
        onSave: _onSave,
      );
    });
  }
}

class CreateOrEditPage extends StatefulWidget {
  final EventType eventType;
  final DateTime selectedDay;
  final List<Event> events;
  final Function onSave;
  final Event event; // null if and only if creating
  final Widget rightButton;

  CreateOrEditPage({
    this.eventType,
    this.events,
    this.selectedDay,
    this.onSave,
    this.event = null,
    this.rightButton = null,
  });

  @override
  _CreateOrEditPageState createState() => _CreateOrEditPageState(
    eventType: eventType,
    selectedDay: selectedDay,
    events: events,
    onSave: onSave,
    event: event,
    rightButton: rightButton,
  );
}

class _CreateOrEditPageState extends State<CreateOrEditPage> {
  final EventType eventType;
  final List<Event> events;
  final Function onSave;
  final Event event; // null if and only if creating
  final Widget rightButton;
  DateTime selectedDay;
  TextEditingController _controller;

  _CreateOrEditPageState({
    this.eventType,
    this.events,
    this.selectedDay,
    this.onSave,
    this.event = null,
    this.rightButton = null,
  });

  void initState() {
    super.initState();
    String text = event?.description ?? '';
    _controller = TextEditingController(text: text);
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDay,
      firstDate: selectedDay.subtract(new Duration(days: 600)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDay) {
	  if (_dateIsUnique(picked)) {
      	setState(() {
        	selectedDay = picked;
      	});
	  } else {
        await _showNonUniqueDateDialog(context, picked);
      }
    }
  }

  bool _dateIsUnique(DateTime selectedDT) {
    if (this.event != null && _isSameDay(selectedDT, this.event.datetime)) {
      // we must be editing an event. It's okay to have an event with the same day as itself
      return true;
    }
	return !this.events.any((event) {
		return _isSameDay(event.datetime, selectedDT);
	  }
	);
  }

  Future _showNonUniqueDateDialog(BuildContext context, DateTime selectedDT) async {
    Event e = this.events.firstWhere((ev) => _isSameDay(ev.datetime, selectedDT));
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        String date = DateFormat.MMMMEEEEd().format(selectedDT);
        return AlertDialog(
          title: Text("Invalid Date Selected"),
          content: Text('There is already an event logged for ${date}. Would you like to go edit that one instead?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.pop(context);
              }
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () => Navigator.popAndPushNamed(context, '/edit', arguments: e)
            ),
          ],
        );
      }
    );
  }


  Widget _buttons(BuildContext context) {
    String type = STRINGS[eventType];
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
                    MaterialStateProperty.all<Color>(TYPE_COLORS[eventType]),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                side: MaterialStateProperty.all<BorderSide>(
                    BorderSide(width: 1, color: Colors.black)),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.all(16)),
              ),
              onPressed: () {
                if (_dateIsUnique(selectedDay)) {
                  this.onSave(context, selectedDay, _controller.text, eventType, event);
                } else {
                  _showNonUniqueDateDialog(context, selectedDay);
                }
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
    String date = DateFormat.MMMMEEEEd().format(selectedDay);
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
        ),
        margin: EdgeInsets.only(right: 18.0, bottom: 18.0, top: 18.0),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 12, right: 12),
                child: Text(
                  "${date}",
                  style: TextStyle(fontSize: 18),
              )),
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

  Widget _topRow(BuildContext context) {
      List<Widget> children = [
          _datePicker(context),
          Spacer(flex: 1),
        ];
      if (rightButton != null) {
        children.add(rightButton);
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.all(12.0),
            child: Column(children: <Widget>[
              _topRow(context),
              _textField(context),
              _buttons(context),
            ])));
  }
}

bool _isSameDay(DateTime dayA, DateTime dayB) {
  return dayA.year == dayB.year &&
      dayA.month == dayB.month &&
      dayA.day == dayB.day;
}

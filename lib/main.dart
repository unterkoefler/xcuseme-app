import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:xcuseme/model.dart';
import 'package:xcuseme/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

const ICON_SIZE = 30.0;
const SMALL_ICON_SIZE = 18.0;
const PARAGRAPH_FONT_SIZE = 14.0;
const HEADING_FONT_SIZE = 28.0;
const SMALL_HEADING_FONT_SIZE = 18.0;
const LOADING_TITLE_FONT_SIZE = 36.0;
const TITLE_FONT_SIZE = 28.0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    ChangeNotifierProvider<Model>(
      create: (context) => Model([]),
      child: InitializationWrapper(),
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
        '/': (context) =>
            AuthProvider(child: HomePageContainer(), currentRoute: '/'),
        '/log-excuse': (context) => AuthProvider(
            child: CreatePageContainer(EventType.EXCUSE),
            currentRoute: '/log-excuse'),
        '/log-exercise': (context) => AuthProvider(
            child: CreatePageContainer(EventType.EXERCISE),
            currentRoute: '/log-exercise'),
        '/info': (context) =>
            AuthProvider(child: InfoPage(), currentRoute: '/info'),
        '/details': (context) =>
            AuthProvider(child: DetailsPage(), currentRoute: '/details'),
        '/edit': (context) =>
            AuthProvider(child: EditPageContainer(), currentRoute: '/edit'),
      },
    );
  }
}

class InitializationWrapper extends StatelessWidget {
  Future<FirebaseApp> _firebaseApp = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _firebaseApp,
      builder: (BuildContext context, AsyncSnapshot<FirebaseApp> snapshot) {
        if (snapshot.hasData) {
          return XCuseMeApp();
        } else if (snapshot.hasError) {
          return Material(child: Text('uh oh'));
        } else {
          return MaterialApp(home: LoadingPage());
        }
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
          ),
        ),
        TextField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Password',
          ),
        ),
        RaisedButton(
          onPressed: () async {
            String msg = await context.read<AuthenticationService>().login(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );
            print(msg);
          },
          child: Text('Login'),
        ),
      ],
    ));
  }
}

class AuthProvider extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  AuthProvider({this.child, this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
        ),
      ],
      child: AuthWrapper(child: child, currentRoute: currentRoute),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  AuthWrapper({this.child, this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      return XCuseMeScaffold(body: child, currentRoute: currentRoute);
    } else {
      return Material(child: LoginPage());
    }
  }
}

class XCuseMeScaffold extends StatelessWidget {
  final Widget body;
  final String currentRoute;

  XCuseMeScaffold({this.body, this.currentRoute});

  Widget _drawerItem(BuildContext context,
      {IconData iconData, String title, String route}) {
    return ListTile(
      leading: Icon(iconData),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // always pop the drawer
        if (route == '/') {
          Navigator.popUntil(context, (r) => r.isFirst);
        } else if (route != currentRoute) {
          Navigator.pushNamedAndRemoveUntil(context, route, (r) => r.isFirst);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text('XCuseMe', style: TextStyle(color: Colors.white)),
            centerTitle: true,
            flexibleSpace: Container(
                decoration: BoxDecoration(
              color: Colors.indigo[100],
            ))),
        body: this.body,
        drawer: Drawer(
            child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo[100],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'XcuseMe',
                    style: TextStyle(
                        fontSize: HEADING_FONT_SIZE, color: Colors.white),
                  ),
                  Text('The exercise tracking app for real people',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: PARAGRAPH_FONT_SIZE,
                          color: Colors.black)),
                ],
              ),
            ),
            _drawerItem(context,
                iconData: Icons.home, title: 'Home', route: '/'),
            _drawerItem(context,
                iconData: Icons.info, title: 'About', route: '/info'),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                context.read<AuthenticationService>().logout();
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              },
            ),
          ],
        )));
  }
}

const Map<EventType, String> PATHS = {
  EventType.EXCUSE: '/log-excuse',
  EventType.EXERCISE: '/log-exercise'
};
const Map<EventType, String> BUTTON_LABELS = {
  EventType.EXCUSE: 'Log Excuse',
  EventType.EXERCISE: 'Log Exercise'
};
const Map<EventType, Color> TYPE_COLORS = {
  EventType.EXCUSE: Color(0xffef9a9a), // Colors.red[200]
  EventType.EXERCISE: Color(0xff80cbc4) // Colors.teal[200]
};
const Map<EventType, IconData> TYPE_ICONS = {
  EventType.EXCUSE: Icons.hotel,
  EventType.EXERCISE: Icons.directions_run,
};
const Map<EventType, String> STRINGS = {
  EventType.EXCUSE: 'Excuse',
  EventType.EXERCISE: 'Exercise',
};

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
    return Scaffold(
        body: SizedBox.expand(
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
                              fontSize: LOADING_TITLE_FONT_SIZE,
                              color: Colors.deepPurple[500])),
                      SizedBox(height: 8.0),
                      Text('The exercise tracking app for real people',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: PARAGRAPH_FONT_SIZE,
                              color: Colors.black)),
                    ],
                  )),
                  _loadingIndicator(context)
                ]))));
  }
}

class DetailsPage extends StatelessWidget {
  Widget _editButton(BuildContext context, Event e) {
    return IconButton(
      icon: Icon(Icons.edit, color: Colors.blue[800], size: ICON_SIZE),
      onPressed: () => Navigator.pushNamed(context, '/edit', arguments: e),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Event event = ModalRoute.of(context).settings.arguments;
    final DateTime dt = event.datetime;
    final String title = '${STRINGS[event.type]} Details';
    final Color color = TYPE_COLORS[event.type];
    String date = DateFormat.MMMMEEEEd().format(dt);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(title,
                  style: TextStyle(color: color, fontSize: HEADING_FONT_SIZE)),
              _editButton(context, event),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 24, right: 24, bottom: 8),
          child: Text(date,
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: PARAGRAPH_FONT_SIZE + 2.0)),
        ),
        Container(
          padding: EdgeInsets.only(left: 24, right: 24, top: 8),
          child: Text(event.description,
              style: TextStyle(fontSize: PARAGRAPH_FONT_SIZE)),
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
            decoration: BoxDecoration(color: Colors.grey[200]),
            child: SingleChildScrollView(
                child: Container(
              padding: EdgeInsets.all(24),
              child: RichText(
                  text: TextSpan(
                text: info_pre,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: PARAGRAPH_FONT_SIZE + 2,
                    height: 1.5),
                children: <TextSpan>[
                  TextSpan(
                    text: 'the Github repository',
                    style: TextStyle(
                        color: Colors.blue[800],
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch('https://github.com/unterkoefler/xcuseme');
                      },
                  ),
                  TextSpan(text: info_post),
                ],
              )),
            ))));
  }
}

class HomePageContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Model>(builder: (context, model, child) {
      return HomePage(model);
    });
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class HomePage extends StatelessWidget {
  final Model model;

  HomePage(this.model);

  bool _shouldDisableLogButtons() {
    return this.model.events.any((event) {
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
            onPressed: _shouldDisableLogButtons()
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

class XCuseList extends StatelessWidget {
  final Model model;

  XCuseList(this.model);

  Widget build(BuildContext context) {
    List<Event> events = model.events;
    if (events.isEmpty) {
      return Text("Nothing logged yet...",
          style: TextStyle(
              fontSize: SMALL_HEADING_FONT_SIZE, fontStyle: FontStyle.italic));
    }
    events.sort((a, b) => b.millis.compareTo(a.millis));

    return Expanded(
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
      size: ICON_SIZE,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    String date = DateFormat.Md().format(event.datetime);
    String title = "$date - ${event.description}";
    return ListTile(
      onTap: () => Navigator.pushNamed(context, '/details', arguments: event),
      leading: _icon(context),
      //dense: true,
      title: Text(
        title,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: SizedBox(
          height: double.infinity,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Details", style: TextStyle(color: Colors.blueGrey[300])),
              Icon(Icons.navigate_next,
                  size: SMALL_ICON_SIZE, color: Colors.blueGrey[300]),
            ],
          )),
    );
  }
}

class CreateEventTile extends StatelessWidget {
  Widget _dialogOption(BuildContext context, EventType type) {
    String next = PATHS[type];
    String label = BUTTON_LABELS[type];
    Color color = TYPE_COLORS[type];

    return SimpleDialogOption(
      onPressed: () {
        Navigator.pushReplacementNamed(context, next);
      },
      child: Text(label,
          style: TextStyle(fontSize: SMALL_HEADING_FONT_SIZE, color: color)),
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
      leading: Icon(Icons.help, size: ICON_SIZE, color: Colors.blueGrey[300]),
      title: Text('Nothing logged for selected day',
          style: TextStyle(fontSize: PARAGRAPH_FONT_SIZE)),
      onTap: () => _showDialog(context),
      //dense: true,
      trailing:
          /* SizedBox(
      //  height: double.infinity,
        child: */
          Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Add', style: TextStyle(color: Colors.blueGrey[300])),
          Icon(Icons.navigate_next,
              size: SMALL_ICON_SIZE, color: Colors.blueGrey[300]),
        ],
      ),
      //  ),
    );
  }
}

class XCuseCalendar extends StatelessWidget {
  final Model model;

  XCuseCalendar(this.model);

  Map<DateTime, List<Event>> _eventsForCal() {
    Map<DateTime, List<Event>> evs = Map();
    model.events.forEach((event) {
      evs[event.datetime] = [event];
    });
    return evs;
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
      calendarController: model.calendarController,
      initialSelectedDay: model.selectedDay ?? DateTime.now(),
      endDay: DateTime.now(),
      events: _eventsForCal(),
      calendarStyle: CalendarStyle(
        selectedColor: Colors.blue[800],
        todayColor: Colors.blue[200],
        weekendStyle: TextStyle(color: Colors.black),
        outsideWeekendStyle: TextStyle(color: Colors.grey[500]),
        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
        cellMargin: EdgeInsets.all(3.0),
      ),
      daysOfWeekStyle:
          DaysOfWeekStyle(weekendStyle: TextStyle(color: Colors.grey[700])),
      onDaySelected: _onDaySelected,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
      },
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        decoration: BoxDecoration(
          color: Colors.indigo[100],
        ),
        titleTextStyle:
            TextStyle(color: Colors.white, fontSize: SMALL_HEADING_FONT_SIZE),
        headerMargin: EdgeInsets.only(bottom: 12.0),
        headerPadding: EdgeInsets.symmetric(vertical: 0.0),
      ),
      builders:
          CalendarBuilders(markersBuilder: (context, date, events, holidays) {
        if (events.isNotEmpty &&
            !model.calendarController.isSelected(date) &&
            !model.calendarController.isToday(date)) {
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
    return Expanded(
        child: Column(
      children: <Widget>[
        Expanded(child: SingleChildScrollView(child: _calendar(context))),
        const Divider(),
        _eventForSelectedDay(context),
        const Divider()
      ],
    ));
  }
}

class EditPageContainer extends StatelessWidget {
  Future<void> _onSave(BuildContext context, DateTime selectedDay,
      String description, EventType eventType, Event event) async {
    Event newEvent = await Provider.of<Model>(context, listen: false)
        .updateEvent(event, selectedDay, description);

    Navigator.pushNamedAndRemoveUntil(
        context, '/details', (route) => route.isFirst,
        arguments: newEvent);
  }

  Widget _deleteButton(BuildContext context, Event e) {
    return IconButton(
      icon: Icon(Icons.delete, color: Colors.blue[800], size: ICON_SIZE),
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
                  }),
              TextButton(
                  child: Text('Delete'),
                  onPressed: () async {
                    await Provider.of<Model>(context, listen: false)
                        .deleteEvent(e);
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (_) => false);
                  }),
            ],
          );
        });
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

  void _onSave(BuildContext context, DateTime selectedDay, String description,
      EventType eventType, Event _) {
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
    this.event,
    this.rightButton,
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
    this.event,
    this.rightButton,
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
    if (this.event != null && isSameDay(selectedDT, this.event.datetime)) {
      // we must be editing an event. It's okay to have an event with the same day as itself
      return true;
    }
    return !this.events.any((event) {
      return isSameDay(event.datetime, selectedDT);
    });
  }

  Future _showNonUniqueDateDialog(
      BuildContext context, DateTime selectedDT) async {
    Event e =
        this.events.firstWhere((ev) => isSameDay(ev.datetime, selectedDT));
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          String date = DateFormat.MMMMEEEEd().format(selectedDT);
          return AlertDialog(
            title: Text("Invalid Date Selected"),
            content: Text(
                'There is already an event logged for $date. Would you like to go edit that one instead?'),
            actions: <Widget>[
              TextButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              TextButton(
                  child: Text('Yes'),
                  onPressed: () => Navigator.popAndPushNamed(context, '/edit',
                      arguments: e)),
            ],
          );
        });
  }

  Widget _buttons(BuildContext context) {
    String type = STRINGS[eventType];
    return Row(children: <Widget>[
      Expanded(
          flex: 3,
          child: ElevatedButton(
              child: Text("Cancel",
                  style: TextStyle(fontSize: SMALL_HEADING_FONT_SIZE)),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.red[500]),
                side: MaterialStateProperty.all<BorderSide>(
                    BorderSide(width: 1, color: Colors.red[500])),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.all(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
              })),
      Spacer(flex: 1),
      Expanded(
          flex: 3,
          child: ElevatedButton(
              child: Text("Save $type",
                  style: TextStyle(fontSize: SMALL_HEADING_FONT_SIZE)),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(TYPE_COLORS[eventType]),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                side: MaterialStateProperty.all<BorderSide>(
                    BorderSide(width: 1, color: Colors.grey[600])),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.all(12)),
              ),
              onPressed: () {
                if (_dateIsUnique(selectedDay)) {
                  this.onSave(
                      context, selectedDay, _controller.text, eventType, event);
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
                  "$date",
                  style: TextStyle(fontSize: SMALL_HEADING_FONT_SIZE),
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
              SizedBox(height: 4.0),
              _buttons(context),
            ])));
  }
}

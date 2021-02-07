import 'package:flutter/material.dart';
import 'package:xcuseme/constants/style.dart';
import 'package:provider/provider.dart';
import 'package:xcuseme/authentication_service.dart';

class XCuseMeDrawer extends StatelessWidget {
  final String currentRoute;

  XCuseMeDrawer({this.currentRoute});

  Widget _drawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.indigo[100],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'XcuseMe',
            style: TextStyle(fontSize: HEADING_FONT_SIZE, color: Colors.white),
          ),
          Text('The exercise tracking app for real people',
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: PARAGRAPH_FONT_SIZE,
                  color: Colors.black)),
        ],
      ),
    );
  }

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
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        _drawerHeader(context),
        _drawerItem(context, iconData: Icons.home, title: 'Home', route: '/'),
        _drawerItem(context,
            iconData: Icons.bar_chart, title: 'Stats', route: '/stats'),
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
    ));
  }
}

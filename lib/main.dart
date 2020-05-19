import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_treeview/tree_view.dart';
import 'section.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flushbar/flushbar_route.dart' as route;
import 'setttings.dart';

bool status = true; // need to change to false
const users = const {
  'admin@test.com': '12345',
  'supervisor@test.com': '12345',
  'operator@test.com': '12345'
};
String currentUser = "admin"; // need to delete admin
bool onBoard = false;

List<String> breadcrumbs = [
  'Home',
];
int currentIndex = 0;
String time1 = "Current Shift : 19-May-20 (Tue) 07:00 - 19-May-20 (Tue) 19:00";
String time2 =
    "Current Shift : 19-May-2020 (Tue) 19:00 - 20-May-2020 (Wed) 07:00";
String time3 =
    "Current Shift : 20-May-2020 (Wed) 07:00 AM - 20-May-2020 (Wed) 01:00 PM";
String time4 =
    "Current Shift : Wed, May-20-2020 13:00 - Wed, May-20-2020 19:00 | Local Time: Wed, May-20-2020 15:31";

String selectedTime = time1;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StartPage();
  }
}

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return status == true
        ? MaterialApp(
            title: 'Mobile App',
            debugShowCheckedModeBanner: false,
            home: HomePage())
        : MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen());
  }
}

class LoginScreen extends StatelessWidget {
  Duration get loginTime => Duration(milliseconds: 2250);

  Future<String> _authUser(LoginData data) {
    print(data.name);
    String name = data.name.trim();
    String password = data.password.trim();
    print(name);
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'Username not exists';
      }
      if (users[name] != password) {
        return 'Password does not match';
      }
      currentUser = name;
      status = true;
      return null;
    });
  }



  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'CNOTES',
      titleTag: 'CSoft Technologies',
      messages: LoginMessages(
        signupButton: '',
        forgotPasswordButton: '',
      ),
      onLogin: _authUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => HomePage(),
        ));
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Downstream & Chemicals',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              breadcrumbs = [
                'Home',
              ];
              currentIndex = 0;
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return LoginScreen();
              }));
            },
          ),
          // action button
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return SettingPage();
              }));
            },
          ),
        ],
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Card(
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Image.asset(
                  'images/oilgas.jpg',
                  fit: BoxFit.fill,
                  height: 180,
                  width: double.infinity,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                elevation: 5,
                margin: EdgeInsets.all(0),
              ),
              SizedBox(
                height: 3,
              ),
              TreeViewWidget(refresh: () {
                setState(() {});
              }),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Logged in as $currentUser", style: TextStyle(
                  fontWeight: FontWeight.bold
                ),),
              ),
            ],
          ),
        ),
      ),
      body: BodyPage(),
    );
  }
}

class BodyPage extends StatefulWidget {
  @override
  _BodyPageState createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  static String welcome = "Welcome " + currentUser.split("@")[0];
  final Flushbar flushbar = Flushbar(
    message: welcome,
    duration: Duration(seconds: 3),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!onBoard) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showFlushbar(flushbar, context);
      });
      onBoard = true;
    }

    return Container(
//          margin: EdgeInsets.all(8),
      child: Column(
        children: [
          BreadCrumbCustom(refresh: () {
            setState(() {});
          }),
          TimerCard(),
          PageContent(),
        ],
      ),
    );
  }

  Future showFlushbar(Flushbar instance, BuildContext context) {
    final _route = route.showFlushbar(
      context: context,
      flushbar: instance,
    );

    return Navigator.of(context, rootNavigator: true).push(_route);
  }
}

class TreeViewWidget extends StatefulWidget {
  const TreeViewWidget({this.refresh});

  final Function refresh;

  @override
  _TreeViewWidgetState createState() => _TreeViewWidgetState();
}

class _TreeViewWidgetState extends State<TreeViewWidget> {
  Future<List<Node>> futureSection;
  String _selectedNode;
  List<Node> _nodes;
  TreeViewController _treeViewController;
  bool docsOpen = true;
  ExpanderPosition _expanderPosition = ExpanderPosition.end;
  ExpanderType _expanderType = ExpanderType.chevron;
  ExpanderModifier _expanderModifier = ExpanderModifier.none;
  bool _allowParentSelect = false;
  bool _supportParentDoubleTap = false;

  @override
  void initState() {
    futureSection = getSection(currentUser.split("@")[0]);
    super.initState();
  }

  void fetchSection() {
    setState(() {
      _treeViewController = TreeViewController(
        children: _nodes,
        selectedKey: _selectedNode,
      );
      _treeViewController = TreeViewController(
        children: _nodes,
        selectedKey: _selectedNode,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    TreeViewTheme _treeViewTheme = TreeViewTheme(
      expanderTheme: ExpanderThemeData(
        type: _expanderType,
        modifier: _expanderModifier,
        position: _expanderPosition,
        color: Colors.grey.shade800,
        size: 20,
      ),
      labelStyle: TextStyle(
        fontSize: 16,
        letterSpacing: 0.3,
      ),
      parentLabelStyle: TextStyle(
        fontSize: 16,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w800,
        color: Colors.blue.shade700,
      ),
      iconTheme: IconThemeData(
        size: 18,
        color: Colors.grey.shade800,
      ),
      colorScheme: Theme.of(context).brightness == Brightness.light
          ? ColorScheme.light(
              primary: Colors.blue.shade50,
              onPrimary: Colors.grey.shade900,
              background: Colors.transparent,
              onBackground: Colors.black,
            )
          : ColorScheme.dark(
              primary: Colors.black26,
              onPrimary: Colors.white,
              background: Colors.transparent,
              onBackground: Colors.white70,
            ),
    );
    return FutureBuilder<List<Node>>(
      future: futureSection,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _treeViewController = TreeViewController(
            children: snapshot.data,
            selectedKey: _selectedNode,
          );
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(10),
              child: TreeView(
                controller: _treeViewController,
                allowParentSelect: _allowParentSelect,
                supportParentDoubleTap: _supportParentDoubleTap,
                onExpansionChanged: (key, expanded) =>
                    _expandNode(key, expanded),
                onNodeTap: (key) {
                  setState(() {
                    switch (key) {
                      case "Shift Supervisor":
                        selectedTime = time1;
                        break;
                      case "Utilities":
                        selectedTime = time2;
                        break;
                      case "Senior Operator":
                        selectedTime = time3;
                        break;
                      case "Console Operator":
                        selectedTime = time4;
                        break;
                      default:
                        selectedTime = time1;
                        break;
                    }
                    breadcrumbs.add(key);
                    breadcrumbs =
                        LinkedHashSet<String>.from(breadcrumbs).toList();
                    _selectedNode = key;
                    _treeViewController =
                        _treeViewController.copyWith(selectedKey: key);
                    Navigator.pop(context);
                    currentIndex = breadcrumbs.indexOf(key);
                    widget.refresh();
                  });
                },
                theme: _treeViewTheme,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return Center(child: Container(child: CircularProgressIndicator()));
      },
    );
  }

  _expandNode(String key, bool expanded) {
    String msg = '${expanded ? "Expanded" : "Collapsed"}: $key';
  }
}

class TimerCard extends StatefulWidget {
  @override
  _TimerCardState createState() => _TimerCardState();
}

class _TimerCardState extends State<TimerCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 1), blurRadius: 3, color: Colors.black26)
          ]),
      padding: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            selectedTime,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

enum ExpanderTypeLan {
  EN,
  KZ,
  RU,
}

class BreadCrumbCustom extends StatefulWidget {
  const BreadCrumbCustom({this.refresh});

  final Function refresh;

  @override
  _BreadCrumbCustomState createState() => _BreadCrumbCustomState();
}

class _BreadCrumbCustomState extends State<BreadCrumbCustom> {
  List<BreadCrumbItem> breadCrumbItem = List<BreadCrumbItem>();
  bool _isHorizontal = true;
  bool _reverse = false;
  bool _lastDivider = false;
  final _scrollController = ScrollController();

  final Map<ExpanderTypeLan, Widget> expansionTypeOptions = const {
    ExpanderTypeLan.EN: Text("EN"),
    ExpanderTypeLan.KZ: Text("KZ"),
    ExpanderTypeLan.RU: Text("RU"),
  };
  ExpanderTypeLan _expanderType = ExpanderTypeLan.EN;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        color: Colors.black26)
                  ]),
              padding: EdgeInsets.all(8),
              child: BreadCrumb.builder(
                itemCount: breadcrumbs.length,
                builder: (index) => BreadCrumbItem(
                  content: Text(
                    breadcrumbs[index],
                    style: TextStyle(
                      fontWeight: currentIndex == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(4),
                  padding: EdgeInsets.all(4),
                  splashColor: Colors.indigo,
                  onTap: () {
                    setState(() {
                      currentIndex = index;
                      String key = breadcrumbs[currentIndex];
                      switch (key) {
                        case "Shift Supervisor":
                          selectedTime = time1;
                          break;
                        case "Utilities":
                          selectedTime = time2;
                          break;
                        case "Senior Operator":
                          selectedTime = time3;
                          break;
                        case "Console Operator":
                          selectedTime = time4;
                          break;
                        default:
                          selectedTime = time1;
                          break;
                      }
                      widget.refresh();
                    });
                  },
                  textColor: Colors.cyan,
                  disabledTextColor: Colors.grey,
                ),
                divider: Icon(
                  Icons.chevron_right,
                  color: Colors.green,
                ),
                overflow: ScrollableOverflow(
                  direction: _isHorizontal ? Axis.horizontal : Axis.vertical,
                  reverse: _reverse,
                  keepLastDivider: _lastDivider,
                  controller: _scrollController,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
              width: double.infinity,
              child: CupertinoSlidingSegmentedControl(
                children: expansionTypeOptions,
                groupValue: _expanderType,
                onValueChanged: (ExpanderTypeLan newValue) {},
              ),
            ),
          )
        ],
      ),
    );
  }
}

class PageContent extends StatefulWidget {
  var state = breadcrumbs[currentIndex];

  @override
  _PageContentState createState() => _PageContentState();
}

class _PageContentState extends State<PageContent> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(0),
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black26)
                ]),
            child: Container(
              padding: EdgeInsets.all(8),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.state} Page",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "This is the subheader of ${widget.state} page",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum. \n\n\n Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, comes from a line in section 1.10.32 \n\n There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc.",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          fontStyle: FontStyle.normal),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

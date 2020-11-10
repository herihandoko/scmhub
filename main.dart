import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/routes.dart';

void main() => runApp(MyHub());
class MyHub extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return new MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SCM Hub',
        home: new AnimatedSplashScreen(),
        routes: routes
    );
  }
}

class AnimatedSplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}
class SplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  bool _visible = true;
  bool checkValue = false;
  bool checkLogin = false;
  SharedPreferences sharedPreferences;
  AnimationController animationController;
  Animation<double> animation;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Timer _timer;
  int _start = 3;
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  void navigationPageLogin() {
    Navigator.of(context).pushReplacementNamed('/Boarding');
  }

  void navigationPageMember() {
    Navigator.of(context).pushReplacementNamed('/Member');
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    startTimer();
    getCredential();
    animationController = new AnimationController( vsync: this, duration: new Duration(seconds: 2));
    animation = new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => this.setState(() {}));
    animationController.forward();

    setState(() {
      _visible = !_visible;
    });
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  getCredential() async {
    var _duration = new Duration(seconds: _start);
    sharedPreferences = await SharedPreferences.getInstance();
    checkLogin = sharedPreferences.getBool("islogin");
    if (checkLogin != null) {
      if (checkLogin) {
        return new Timer(_duration, navigationPageMember);
      }else{
        return new Timer(_duration, navigationPageLogin);
      }
    }else{
      return new Timer(_duration, navigationPageLogin);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            top:0.0,
            right: 0.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Image.asset(
                'images/logo_scm.png',
                width: animation.value * 60,
                height: animation.value * 60,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'SCM Hub',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(57, 99, 175, 1.0),
                          fontSize: animation.value * 40,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        SizedBox(
                          height: 50.0,
                          child: Stack(
                            children: <Widget>[
                              Center(
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  child: new CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: new AlwaysStoppedAnimation<Color>(Color(0xFF01579B))
                                  ),
                                ),
                              ),
                              Center(child: Text("${_start}s")),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
      bottomNavigationBar: new Container(
        height: 40.0,
        color: Colors.white,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            child: Text('Copyright © 2020 SCM Hub \n Version ${_packageInfo.version}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
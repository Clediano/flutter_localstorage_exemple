import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        storage: ContadorStorage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final ContadorStorage storage;

  MyHomePage({Key key, this.title, this.storage}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class ContadorStorage {
  Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<int> readContador() async {
    try {
      final file = await _localFile;
      String counter = await file.readAsString();
      return int.parse(counter);
    } catch (err) {
      return 0;
    }
  }

  Future<File> writeContador(int counter) async {
    final file = await _localFile;
    return file.writeAsString('$counter');
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _counterFile = 0;
  int _counterPreferences = 0;

  void initState() {
    super.initState();

    widget.storage.readContador().then((int counter) {
      setState(() {
        _counterFile = counter;
      });
    });

    _loadContador();
  }

  _loadContador() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      _counterPreferences = (preferences.getInt('counter') ?? 0);
    });
  }

  _writeContador() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setInt('counter', _counterPreferences);
  }

  Future<File> _incrementCounter() {
    setState(() {
      _counterFile += 1;
      _counterPreferences += 2;
    });

    _writeContador();

    return widget.storage.writeContador(_counterFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Arquivo texto $_counterFile',
              style: Theme.of(context).textTheme.display1,
            ),
            Text(
              'Arquivo preferência $_counterPreferences',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

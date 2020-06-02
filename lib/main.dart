import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class Counter with ChangeNotifier{

  int _value = 0;
  int _step = 1;
  bool _pause = false;

  int get counter => _value;
  int get step => _step;
  bool get isPaused => _pause;

  void incrementStep() {
    _step += 1;
    notifyListeners();
  }

  void decrementStep() {
    _step -= 1;
    notifyListeners();
  }

  void pauseCounter() {
    _pause = !_pause;
    notifyListeners();
  }

  Stream<int> countStream() async* {
    while(true) {
      await Future.delayed(const Duration(seconds: 1));
      if(!_pause) {
        _value += _step;
        yield _value;
      }
    }
  }

}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Counter>(
          create: (context) => Counter(),
        ),
        StreamProvider<int>(
          create: (context) => Provider.of<Counter>(context, listen: false).countStream(),
          initialData: 0,
          catchError: (context, error) {
            print(error.toString());
            return 0;
          },
        ),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: MyHomePage(title: 'Flutter Demo Home Page'),
        ),
      );
  }
}

class MyHomePage extends StatelessWidget {
  final title;
  MyHomePage({this.title});
  @override
  Widget build(BuildContext context) {
    print("Homepage rebuild");
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'The counter has ticked this many times:',
            ),
            Consumer<int>(
              builder: (context, count, child) {
                return Text(
                  '$count',
                  style: Theme.of(context).textTheme.headline4,
                );
              },
            ),
            Consumer<Counter>(
              builder: (context, counter, child) {
                return Text(
                    'Step: ${counter.step}',
                    style: Theme.of(context).textTheme.headline5
                );
              }
            ),
            Consumer<Counter>(
              builder:(context, counter, child) {
                return RaisedButton(
                  child: (counter.isPaused) ?
                      Text('resume')
                  : Text('pause'),
                  onPressed: () => counter.pauseCounter(),
                );
              }
            )
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () => {
              Provider.of<Counter>(context, listen: false).incrementStep()
            },
            tooltip: 'Increment step',
            child: Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () => {
              Provider.of<Counter>(context, listen: false).decrementStep()
            },
            tooltip: 'Decrement step',
            child: Icon(Icons.remove),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

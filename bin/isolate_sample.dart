import 'dart:async';
import 'dart:isolate';

import 'package:dart_isolate_sample/isolate_handler.dart';

void main(List<String> args) {
  print('Application started');
  var isolateHandler = IsolateHandler();
  isolateHandler.isolateReady.then((sender) {
    var count = 0;
    Timer.periodic(Duration(seconds: 1), (_) {
      var original = 'Counter: ${count++}';
      print('Main: $original');
      sender.send(original);
    });
  });

  isolateHandler.stream.listen((message) {
    print('Isolate: $message');
  });
}

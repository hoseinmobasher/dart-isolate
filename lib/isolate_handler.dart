import 'dart:async';
import 'dart:isolate';

/*
 * Spawn new isolate and communicate with each other.
 * 
 * Isolate 1 [receive_port_1, send_port_1] ----------------- [receive_port_2, send_port_2] Isolate 2
 * 
 */
class IsolateHandler<T> {
  Isolate _isolate;
  final _completer = Completer<SendPort>();
  final _controller = StreamController<T>();

  Future<SendPort> get isolateReady => _completer.future;
  Stream<T> get stream => _controller.stream;

  IsolateHandler() {
    init();
  }

  void init() async {
    final selfReceiverPort = ReceivePort();
    selfReceiverPort.listen(_handleMessage);

    _isolate = await Isolate.spawn(_entryPoint, selfReceiverPort.sendPort);
  }

  static void _entryPoint(dynamic message) {
    var isolateSendPort;
    final isolateReceiverPort = ReceivePort();

    isolateReceiverPort.listen((dynamic data) {
      assert(data is String);
      isolateSendPort.send((data as String).toUpperCase());
    });

    if (message is SendPort) {
      isolateSendPort = message;
      isolateSendPort.send(isolateReceiverPort.sendPort);
      return;
    }
  }

  void _handleMessage(dynamic message) {
    if (message is SendPort) {
      var selfSendPort = message;
      _completer.complete(selfSendPort);
      return;
    } else {
      _controller.add(message);
    }
  }

  void dispose() {
    _isolate.kill();
  }
}

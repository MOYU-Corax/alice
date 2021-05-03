import 'package:alice/model/alice_http_error.dart';
import 'package:alice/ui/alice_calls_list_screen.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:alice/model/alice_http_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shake/shake.dart';

class AliceCore {
  GlobalKey<NavigatorState> _navigatorKey;
  bool _showInspectorOnShake = false;
  bool _isInspectorOpened = false;
  Brightness _brightness = Brightness.light;

  List<AliceHttpCall> calls;
  PublishSubject<int> changesSubject;
  PublishSubject<AliceHttpCall> callUpdateSubject;
  ShakeDetector shakeDetector;

  AliceCore(GlobalKey<NavigatorState> navigatorKey, bool showNotification,
      bool showInspectorOnShake, bool darkTheme) {
    _navigatorKey = navigatorKey;
    calls = List();
    changesSubject = PublishSubject();
    callUpdateSubject = PublishSubject();
    _showInspectorOnShake = showInspectorOnShake;
    if (_showInspectorOnShake) {
      shakeDetector = ShakeDetector.autoStart(
        onPhoneShake: () => navigateToCallListScreen(),
        shakeThresholdGravity: 5,
      );
    }
    _brightness = darkTheme ? Brightness.dark : Brightness.light;
  }

  dispose() {
    changesSubject.close();
    callUpdateSubject.close();
    shakeDetector?.stopListening();
  }

  void navigateToCallListScreen() {
    var context = getContext();
    if (context == null) {
      print(
          "Cant start Alice HTTP Inspector. Please add NavigatorKey to your application");
      return;
    }
    if (!_isInspectorOpened) {
      _isInspectorOpened = true;
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => AliceCallsListScreen(this)),
      ).then((onValue) => _isInspectorOpened = false);
    }
  }

  BuildContext getContext() {
    if (_navigatorKey != null &&
        _navigatorKey.currentState != null &&
        _navigatorKey.currentState.overlay != null) {
      return _navigatorKey.currentState.overlay.context;
    } else {
      return null;
    }
  }

  void addCall(AliceHttpCall call) {
    calls.add(call);
  }

  void addError(AliceHttpError error, int requestId) {
    AliceHttpCall selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      print("Selected call is null");
      return;
    }

    selectedCall.error = error;
    changesSubject.sink.add(requestId);
    callUpdateSubject.sink.add(selectedCall);
  }

  void addResponse(AliceHttpResponse response, int requestId) {
    AliceHttpCall selectedCall = _selectCall(requestId);

    if (selectedCall == null) {
      print("Selected call is null");
      return;
    }
    selectedCall.loading = false;
    selectedCall.response = response;
    selectedCall.duration = response.time.millisecondsSinceEpoch -
        selectedCall.request.time.millisecondsSinceEpoch;

    changesSubject.sink.add(requestId);
    callUpdateSubject.sink.add(selectedCall);
  }

  void removeCalls() {
    calls = List();
    changesSubject.sink.add(0);
  }

  AliceHttpCall _selectCall(int requestId) {
    AliceHttpCall requestedCall;
    calls.forEach((call) {
      if (call.id == requestId) {
        requestedCall = call;
      }
    });
    return requestedCall;
  }

  void saveHttpRequests(BuildContext context) {
    // AliceSaveHelper.saveCalls(context, calls);
  }

  Brightness get brightness => _brightness;
}

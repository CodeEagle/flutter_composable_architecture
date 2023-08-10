import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_composable_architecture/flutter_composable_architecture.dart';

void main() {
  test('adds one to input values', () async {
    final store = Store(
      initialLogic: () => AppLogic(),
      middleware: [const LoggingMiddleware()],
    );

    store.stateStream.listen((info) {
      debugPrint('State changed: ${info.changes}');
    });

    await store.send(const DeviceDisconnectAction());
    assert(store.logic.state.subSystemState.connected == false);
    await store.send(const DeviceConnectAction());
    assert(store.logic.state.subSystemState.connected == true);
    await store.send(const DeviceConnectAction());
    assert(store.logic.state.subSystemState.connected == true);
    await store.send(const DeviceDisconnectAction());
    assert(store.logic.state.subSystemState.connected == false);
  });
}

class LoggingMiddleware extends MiddlewareCompatible<AppState, AppAction> {
  const LoggingMiddleware();

  @override
  Future<AppAction> beforeReduce(AppAction action, AppState state) async {
    debugPrint('Action: $action');
    return action;
  }
}

class AppLogic extends LogicCompatible<AppState, AppAction> {
  AppLogic();

  late final subSystemLogic = SubSystemLogic(state);

  @override
  Future<Effect<AppAction>?> reduce(AppAction action) async {
    if (action is SubSystemAction) {
      return subSystemLogic.reduce(action);
    }
    return null;
  }

  @override
  AppState state = AppState();
}

class AppState extends StateCompatible<AppState> {
  SubSystemState subSystemState = SubSystemState();

  AppState copyWith({
    SubSystemState? subSystemState,
  }) {
    return AppState()..subSystemState = subSystemState ?? this.subSystemState.copy();
  }

  @override
  List diff(old) {
    final subSystemStateChanges = subSystemState.diff(old.subSystemState);

    return [
      ...subSystemStateChanges,
    ];
  }

  @override
  AppState copy() => copyWith();

  @override
  String toString() {
    return subSystemState.toString();
  }
}

abstract class AppAction {
  const AppAction();
}

class OtherAppAction extends AppAction {
  const OtherAppAction();
}

class SubSystemLogic extends LogicCompatible<SubSystemState, AppAction> {
  SubSystemLogic(this.appState);

  @override
  Future<Effect<AppAction>?> reduce(AppAction action) async {
    switch (action.runtimeType) {
      case DeviceConnectAction:
        state.connected = true;
        break;
      case DeviceDisconnectAction:
        state.connected = false;
        break;
    }
    return Effect.action(const OtherAppAction());
  }

  final AppState appState;

  @override
  SubSystemState get state => appState.subSystemState;
}

class SubSystemState extends StateCompatible<SubSystemState> {
  bool connected = false;

  SubSystemState copyWith({
    bool? connected,
  }) {
    return SubSystemState()..connected = connected ?? this.connected;
  }

  @override
  List diff(old) {
    List<Object> changed = [];
    if (old.connected != connected) {
      changed.add('connected');
    }
    return changed;
  }

  @override
  SubSystemState copy() => copyWith();

  @override
  String toString() {
    return 'SubSystemState{connected: $connected}';
  }
}

abstract class SubSystemAction extends AppAction {
  const SubSystemAction();
}

class DeviceConnectAction extends SubSystemAction {
  const DeviceConnectAction();
}

class DeviceDisconnectAction extends SubSystemAction {
  const DeviceDisconnectAction();
}

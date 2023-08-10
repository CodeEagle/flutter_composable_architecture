import 'dart:async';

part 'effect.dart';
part 'logic.dart';

typedef StoreDispatcher<Action> = Future<void> Function(Action action);

class Store<State extends StateCompatible<State>, Action> {
  Store({
    required LogicCompatible<State, Action> Function() initialLogic,
    List<MiddlewareCompatible<State, Action>> middleware = const [],
  }) {
    _logic = initialLogic();
    _middleware = middleware;
    _previousState = _logic.state.copy();
  }

  late final LogicCompatible<State, Action> _logic;
  LogicCompatible<State, Action> get logic => _logic;
  late State _previousState;

  /// Middleware is a function that takes a `Store`'s state and an `Action`, and may
  /// perform a side effect before optionally returning a new `Action` to be
  /// fed back into the `Store`.
  late final List<MiddlewareCompatible<State, Action>> _middleware;

  final StreamController<StateChangedInfo<State>> _stateStreamController = StreamController.broadcast(sync: true);
  Stream<StateChangedInfo<State>> get stateStream => _stateStreamController.stream;

  Future<void> send(Action action) async {
    final effect = await _processAction(action);
    final eAction = effect?.action;

    if (eAction != null) {
      if (effect?.dispatchChanged == true) {
        _dispatch(_logic.state);
      }

      final a = await eAction(send);
      if (a != null) {
        await send(a);
      } else {
        _dispatch(_logic.state);
      }
    } else {
      _dispatch(_logic.state);
    }
  }

  Future<Effect<Action>?> _processAction(Action action) async {
    Action processedAction = action;
    for (final middleware in _middleware) {
      processedAction = await middleware.beforeReduce(processedAction, _logic.state);
    }
    return await _logic.reduce(processedAction);
  }

  void _dispatch(State state) {
    final info = StateChangedInfo(_previousState, state, state.diff(_previousState));
    if (info.changes.isEmpty) {
      return;
    }
    _stateStreamController.add(info);
    _previousState = state.copy();
  }

  void dispose() {
    logic.dispose();
  }
}

class StateChangedInfo<State> {
  final State previous;
  final State current;
  final List changes;
  const StateChangedInfo(this.previous, this.current, this.changes);
}

abstract class StateCompatible<T extends StateCompatible<T>> {
  const StateCompatible();
  List diff(T old);
  T copy();
}

abstract class MiddlewareCompatible<State, Action> {
  const MiddlewareCompatible();
  Future<Action> beforeReduce(Action action, State state);
}

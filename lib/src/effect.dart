part of 'store.dart';

class Effect<Action> {
  Effect({this.action, this.dispatchChanged = false});

  final bool dispatchChanged;
  final Future<Action?> Function(StoreDispatcher<Action>)? action;

  Effect.action(Action action, {bool dispatchChanged = false})
      : this(action: (dispatcher) async => action, dispatchChanged: dispatchChanged);
}

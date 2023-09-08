part of 'store.dart';

class Effect<Action> {
  Effect({this.action, this.dispatchChanged = false});

  final bool dispatchChanged;
  final Future<Action?> Function(StoreDispatcher<Action>)? action;

  Effect.action(Action action, {bool dispatchChanged = false, Duration? delay})
      : this(
            action: (dispatcher) async {
              if (delay != null) {
                await Future.delayed(delay);
              }
              return action;
            },
            dispatchChanged: dispatchChanged);
}

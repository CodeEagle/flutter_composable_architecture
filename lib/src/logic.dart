part of 'store.dart';

abstract class LogicCompatible<State, Action> {
  State get state;
  Future<Effect<Action>?> reduce(Action action);
  void dispose() {}
  const LogicCompatible();
}

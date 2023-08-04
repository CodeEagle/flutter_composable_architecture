part of 'store.dart';

abstract class Logic<State, Action> {
  State get state;
  Future<Effect<Action>?> reduce(Action action);
}

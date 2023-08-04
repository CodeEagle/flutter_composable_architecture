part of 'store.dart';

class Effect<Action> {
  Effect([this.action]);

  final Future<Action> Function()? action;
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rollit/models/dice_action.model.dart';
import 'package:rollit/services/data.service.dart';

class ActionState {
  final List<DiceAction> actions;

  ActionState({required this.actions});
}

class ActionNotifier extends Notifier<ActionState> {
  @override
  ActionState build() {
    return ActionState(actions: []);
  }

  Future<void> loadActions() async {
    if (state.actions.isNotEmpty) {
      return;
    }

    final List<DiceAction> actions = await DataService.loadActions();

    state = ActionState(actions: actions);
  }
}

final actionProvider = NotifierProvider<ActionNotifier, ActionState>(
  () => ActionNotifier(),
);

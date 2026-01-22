import 'package:flutter_riverpod/flutter_riverpod.dart';

class PartyPlayer {
  final String name;
  final int avatarIndex;

  PartyPlayer({required this.name, required this.avatarIndex});
}

class PartyModeState {
  final List<PartyPlayer> players;
  final List<int> scores;
  final int currentPlayerIndex;
  final int totalRounds;
  final int roundsCompleted;
  final Map<String, int> categoryRollCounts;
  final Map<int, Map<String, int>> playerCategoryRollCounts;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  PartyModeState({
    required this.players,
    required this.scores,
    required this.currentPlayerIndex,
    required this.totalRounds,
    required this.roundsCompleted,
    required this.categoryRollCounts,
    required this.playerCategoryRollCounts,
    required this.startedAt,
    required this.finishedAt,
  });
}

class PartyModeNotifier extends Notifier<PartyModeState> {
  @override
  PartyModeState build() {
    return PartyModeState(
      players: [],
      scores: [],
      currentPlayerIndex: 0,
      totalRounds: 3,
      roundsCompleted: 0,
      categoryRollCounts: {},
      playerCategoryRollCounts: {},
      startedAt: null,
      finishedAt: null,
    );
  }

  void addPlayer(PartyPlayer player) {
    state = PartyModeState(
      players: [...state.players, player],
      scores: [...state.scores, 0],
      currentPlayerIndex: state.currentPlayerIndex,
      totalRounds: state.totalRounds,
      roundsCompleted: state.roundsCompleted,
      categoryRollCounts: state.categoryRollCounts,
      playerCategoryRollCounts: state.playerCategoryRollCounts,
      startedAt: state.startedAt,
      finishedAt: state.finishedAt,
    );
  }

  void removePlayerAt(int index) {
    if (index < 0 || index >= state.players.length) {
      return;
    }
    final updatedPlayers = [...state.players]..removeAt(index);
    final updatedScores = [...state.scores]..removeAt(index);
    int nextIndex = state.currentPlayerIndex;
    if (index < nextIndex) {
      nextIndex -= 1;
    } else if (index == nextIndex) {
      nextIndex = updatedPlayers.isEmpty ? 0 : nextIndex;
      if (nextIndex >= updatedPlayers.length) {
        nextIndex = 0;
      }
    }
    state = PartyModeState(
      players: updatedPlayers,
      scores: updatedScores,
      currentPlayerIndex: nextIndex,
      totalRounds: state.totalRounds,
      roundsCompleted: state.roundsCompleted,
      categoryRollCounts: state.categoryRollCounts,
      playerCategoryRollCounts: state.playerCategoryRollCounts,
      startedAt: state.startedAt,
      finishedAt: state.finishedAt,
    );
  }

  void removePlayer(PartyPlayer player) {
    final index = state.players.indexOf(player);
    if (index == -1) {
      return;
    }
    removePlayerAt(index);
  }

  void updatePlayerAt(int index, PartyPlayer player) {
    if (index < 0 || index >= state.players.length) {
      return;
    }
    final updated = [...state.players];
    updated[index] = player;
    state = PartyModeState(
      players: updated,
      scores: state.scores,
      currentPlayerIndex: state.currentPlayerIndex,
      totalRounds: state.totalRounds,
      roundsCompleted: state.roundsCompleted,
      categoryRollCounts: state.categoryRollCounts,
      playerCategoryRollCounts: state.playerCategoryRollCounts,
      startedAt: state.startedAt,
      finishedAt: state.finishedAt,
    );
  }

  void setTotalRounds(int totalRounds) {
    final sanitized = totalRounds < 1 ? 1 : totalRounds;
    state = PartyModeState(
      players: state.players,
      scores: state.scores,
      currentPlayerIndex: state.currentPlayerIndex,
      totalRounds: sanitized,
      roundsCompleted: 0,
      categoryRollCounts: {},
      playerCategoryRollCounts: {},
      startedAt: null,
      finishedAt: null,
    );
  }

  void _advancePlayer({List<int>? updatedScores}) {
    if (state.players.isEmpty) {
      return;
    }
    final lastIndex = state.players.length - 1;
    final isRoundComplete = state.currentPlayerIndex == lastIndex;
    final nextIndex = (state.currentPlayerIndex + 1) % state.players.length;
    final nextRoundsCompleted = isRoundComplete
        ? state.roundsCompleted + 1
        : state.roundsCompleted;
    state = PartyModeState(
      players: state.players,
      scores: updatedScores ?? state.scores,
      currentPlayerIndex: nextIndex,
      totalRounds: state.totalRounds,
      roundsCompleted: nextRoundsCompleted,
      categoryRollCounts: state.categoryRollCounts,
      playerCategoryRollCounts: state.playerCategoryRollCounts,
      startedAt: state.startedAt,
      finishedAt: state.finishedAt,
    );
  }

  void nextPlayer() {
    _advancePlayer();
  }

  void validateCurrentPlayer({int delta = 1}) {
    if (state.players.isEmpty) {
      return;
    }
    final updatedScores = [...state.scores];
    updatedScores[state.currentPlayerIndex] += delta;
    _advancePlayer(updatedScores: updatedScores);
  }

  void startGameIfNeeded() {
    if (state.startedAt != null) {
      return;
    }
    state = PartyModeState(
      players: state.players,
      scores: state.scores,
      currentPlayerIndex: state.currentPlayerIndex,
      totalRounds: state.totalRounds,
      roundsCompleted: state.roundsCompleted,
      categoryRollCounts: state.categoryRollCounts,
      playerCategoryRollCounts: state.playerCategoryRollCounts,
      startedAt: DateTime.now(),
      finishedAt: null,
    );
  }

  void recordCategoryRoll(String categoryId) {
    if (state.players.isEmpty) {
      return;
    }
    final updatedCategoryCounts = Map<String, int>.from(
      state.categoryRollCounts,
    );
    updatedCategoryCounts[categoryId] =
        (updatedCategoryCounts[categoryId] ?? 0) + 1;

    final updatedPlayerCounts = Map<int, Map<String, int>>.from(
      state.playerCategoryRollCounts,
    );
    final playerIndex = state.currentPlayerIndex;
    final playerCounts = Map<String, int>.from(
      updatedPlayerCounts[playerIndex] ?? {},
    );
    playerCounts[categoryId] = (playerCounts[categoryId] ?? 0) + 1;
    updatedPlayerCounts[playerIndex] = playerCounts;

    state = PartyModeState(
      players: state.players,
      scores: state.scores,
      currentPlayerIndex: state.currentPlayerIndex,
      totalRounds: state.totalRounds,
      roundsCompleted: state.roundsCompleted,
      categoryRollCounts: updatedCategoryCounts,
      playerCategoryRollCounts: updatedPlayerCounts,
      startedAt: state.startedAt ?? DateTime.now(),
      finishedAt: state.finishedAt,
    );
  }

  void undoCategoryRoll(String categoryId) {
    if (state.players.isEmpty) {
      return;
    }

    final updatedCategoryCounts = Map<String, int>.from(
      state.categoryRollCounts,
    );
    final currentCount = updatedCategoryCounts[categoryId] ?? 0;
    if (currentCount > 1) {
      updatedCategoryCounts[categoryId] = currentCount - 1;
    } else {
      updatedCategoryCounts.remove(categoryId);
    }

    final updatedPlayerCounts = Map<int, Map<String, int>>.from(
      state.playerCategoryRollCounts,
    );
    final playerIndex = state.currentPlayerIndex;
    final playerCounts = Map<String, int>.from(
      updatedPlayerCounts[playerIndex] ?? {},
    );
    final playerCount = playerCounts[categoryId] ?? 0;
    if (playerCount > 1) {
      playerCounts[categoryId] = playerCount - 1;
    } else {
      playerCounts.remove(categoryId);
    }
    updatedPlayerCounts[playerIndex] = playerCounts;

    state = PartyModeState(
      players: state.players,
      scores: state.scores,
      currentPlayerIndex: state.currentPlayerIndex,
      totalRounds: state.totalRounds,
      roundsCompleted: state.roundsCompleted,
      categoryRollCounts: updatedCategoryCounts,
      playerCategoryRollCounts: updatedPlayerCounts,
      startedAt: state.startedAt,
      finishedAt: state.finishedAt,
    );
  }

  void markGameFinished() {
    if (state.finishedAt != null) {
      return;
    }
    state = PartyModeState(
      players: state.players,
      scores: state.scores,
      currentPlayerIndex: state.currentPlayerIndex,
      totalRounds: state.totalRounds,
      roundsCompleted: state.roundsCompleted,
      categoryRollCounts: state.categoryRollCounts,
      playerCategoryRollCounts: state.playerCategoryRollCounts,
      startedAt: state.startedAt,
      finishedAt: DateTime.now(),
    );
  }

  void restartGame() {
    state = PartyModeState(
      players: state.players,
      scores: List<int>.filled(state.players.length, 0),
      currentPlayerIndex: 0,
      totalRounds: state.totalRounds,
      roundsCompleted: 0,
      categoryRollCounts: {},
      playerCategoryRollCounts: {},
      startedAt: DateTime.now(),
      finishedAt: null,
    );
  }

  void resetScores() {
    state = PartyModeState(
      players: state.players,
      scores: List<int>.filled(state.players.length, 0),
      currentPlayerIndex: 0,
      totalRounds: state.totalRounds,
      roundsCompleted: 0,
      categoryRollCounts: {},
      playerCategoryRollCounts: {},
      startedAt: null,
      finishedAt: null,
    );
  }
}

final partyModeProvider = NotifierProvider<PartyModeNotifier, PartyModeState>(
  () => PartyModeNotifier(),
);

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rollit/widgets/app_background.widget.dart';
import 'package:rollit/services/i18n.service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rollit/providers/party_mode.provider.dart';
import 'package:rollit/widgets/add_players/avatar_fly_animation.dart';
import 'package:rollit/widgets/add_players/avatar_picker_sheet.dart';
import 'package:rollit/widgets/add_players/draft_player_card.dart';
import 'package:rollit/widgets/add_players/edit_player_sheet.dart';
import 'package:rollit/widgets/add_players/empty_state_card.dart';
import 'package:rollit/widgets/add_players/max_players_banner.dart';
import 'package:rollit/widgets/add_players/players_header.dart';
import 'package:rollit/widgets/add_players/selected_players_grid.dart';
import 'package:rollit/widgets/add_players/start_game_button.dart';

class AddPlayersScreen extends ConsumerStatefulWidget {
  const AddPlayersScreen({super.key});

  @override
  ConsumerState<AddPlayersScreen> createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends ConsumerState<AddPlayersScreen>
    with TickerProviderStateMixin {
  static const int _maxPlayers = 8;
  final List<int> _draftPlayerIds = [];
  int _nextDraftPlayerId = 1;
  int? _focusDraftId;
  final Map<int, GlobalKey> _draftAvatarKeys = {};
  final Map<PartyPlayer, GlobalKey> _playerAvatarKeys = {};
  final Set<PartyPlayer> _animatingPlayers = {};

  GlobalKey _draftAvatarKey(int draftId) {
    return _draftAvatarKeys.putIfAbsent(draftId, () => GlobalKey());
  }

  GlobalKey _playerAvatarKey(PartyPlayer player) {
    return _playerAvatarKeys.putIfAbsent(player, () => GlobalKey());
  }

  Future<int?> _pickAvatar(BuildContext context, {int? selectedAvatarIndex}) {
    return showAvatarPickerSheet(
      context,
      title: I18nKeys.instance.addPlayers.chooseAvatarTitle.tr(),
      selectedAvatarIndex: selectedAvatarIndex,
    );
  }

  Future<void> _showPlayerOptions(int index, PartyPlayer player) async {
    final result = await showEditPlayerSheet(
      context: context,
      player: player,
      playerNameLabel: I18nKeys.instance.addPlayers.playerName.tr(),
      deleteLabel: I18nKeys.instance.addPlayers.editDelete.tr(),
      saveLabel: I18nKeys.instance.addPlayers.editSave.tr(),
      onPickAvatar: (selectedAvatarIndex) =>
          _pickAvatar(context, selectedAvatarIndex: selectedAvatarIndex),
    );

    if (result == null) {
      return;
    }
    if (result.delete) {
      ref.read(partyModeProvider.notifier).removePlayerAt(index);
      _playerAvatarKeys.remove(player);
      return;
    }
    if (result.updatedPlayer != null) {
      final updatedPlayer = result.updatedPlayer!;
      setState(() {
        _playerAvatarKeys.remove(player);
        _playerAvatarKey(updatedPlayer);
      });
      ref.read(partyModeProvider.notifier).updatePlayerAt(index, updatedPlayer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final partyState = ref.watch(partyModeProvider);
    final canStartGame = partyState.players.length >= 2;
    final hasReachedMaxPlayers = partyState.players.length >= _maxPlayers;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(I18nKeys.instance.addPlayers.title.tr()),
          actions: [
            IconButton(
              onPressed: hasReachedMaxPlayers
                  ? null
                  : () {
                      setState(() {
                        final newDraftId = _nextDraftPlayerId++;
                        _draftPlayerIds.add(newDraftId);
                        _focusDraftId = newDraftId;
                      });
                    },
              icon: const Icon(Icons.add, size: 28),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (partyState.players.isEmpty) ...[
                AddPlayersEmptyStateCard(
                  title: I18nKeys.instance.addPlayers.emptyTitle.tr(),
                  subtitle: I18nKeys.instance.addPlayers.emptySubtitle.tr(),
                ),
                const SizedBox(height: 16),
              ],
              if (partyState.players.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PlayersHeader(
                      label: I18nKeys.instance.addPlayers.playersLabel.tr(),
                      tooltipMessage: I18nKeys
                          .instance
                          .addPlayers
                          .maxPlayersHint
                          .tr(),
                      currentCount: partyState.players.length,
                      maxCount: _maxPlayers,
                    ),
                    const SizedBox(height: 10),
                    SelectedPlayersGrid(
                      players: partyState.players,
                      animatingPlayers: _animatingPlayers,
                      avatarKeyBuilder: _playerAvatarKey,
                      onPlayerTap: (index, player) =>
                          _showPlayerOptions(index, player),
                    ),
                  ],
                ),
              if (hasReachedMaxPlayers) ...[
                const SizedBox(height: 12),
                MaxPlayersBanner(
                  message: I18nKeys.instance.addPlayers.maxPlayersReached.tr(),
                ),
              ],
              if (partyState.players.isNotEmpty) const SizedBox(height: 20),
              for (final draftId in _draftPlayerIds)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DraftPlayerCard(
                    avatarKey: _draftAvatarKey(draftId),
                    autofocus: _focusDraftId == draftId,
                    onPickAvatar: (selectedAvatarIndex) => _pickAvatar(
                      context,
                      selectedAvatarIndex: selectedAvatarIndex,
                    ),
                    playerNameLabel: I18nKeys.instance.addPlayers.playerName
                        .tr(),
                    onRemove: () {
                      setState(() {
                        _draftAvatarKeys.remove(draftId);
                        _draftPlayerIds.remove(draftId);
                        if (_focusDraftId == draftId) {
                          _focusDraftId = null;
                        }
                      });
                    },
                    onValidate: (name, avatarIndex) {
                      if (partyState.players.length >= _maxPlayers) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              I18nKeys.instance.addPlayers.maxPlayersReached
                                  .tr(),
                            ),
                          ),
                        );
                        return;
                      }
                      final player = PartyPlayer(
                        name: name,
                        avatarIndex: avatarIndex,
                      );
                      setState(() {
                        _animatingPlayers.add(player);
                        if (_focusDraftId == draftId) {
                          _focusDraftId = null;
                        }
                      });
                      final targetKey = _playerAvatarKey(player);
                      ref.read(partyModeProvider.notifier).addPlayer(player);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        animateAvatarToGrid(
                          context: context,
                          vsync: this,
                          fromKey: _draftAvatarKey(draftId),
                          toKey: targetKey,
                          avatarIndex: avatarIndex,
                          name: name,
                          onComplete: () {
                            if (mounted) {
                              setState(() {
                                _animatingPlayers.remove(player);
                              });
                            }
                          },
                        );
                      });
                    },
                  ),
                ),
              if (partyState.players.isNotEmpty)
                StartGameButton(
                  label: I18nKeys.instance.addPlayers.startGame.tr(),
                  enabled: canStartGame,
                  onPressed: () => Navigator.pushNamed(context, '/party_mode'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

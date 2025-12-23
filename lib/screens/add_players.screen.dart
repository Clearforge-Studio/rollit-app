import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rollit/widgets/app_background.widget.dart';
import 'package:rollit/services/i18n.service.dart';
import 'package:easy_localization/easy_localization.dart';

class AddPlayersScreen extends ConsumerStatefulWidget {
  const AddPlayersScreen({super.key});

  @override
  ConsumerState<AddPlayersScreen> createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends ConsumerState<AddPlayersScreen> {
  int _playerCount = 1;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(I18nKeys.instance.addPlayers.title.tr()),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _playerCount++;
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
              for (int i = 0; i < _playerCount; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Dismissible(
                    key: ValueKey(Random().nextInt(1 << 32)),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        _playerCount = (_playerCount - 1)
                            .clamp(0, double.infinity)
                            .toInt();
                      });
                    },
                    child: _PlayerCard(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/**
 * TODO:
 */
// TODO: add button to validate player
// player card will shrink into just an avatar with name below to make room for more players
class _PlayerCard extends StatefulWidget {
  const _PlayerCard({super.key});

  @override
  State<_PlayerCard> createState() => __PlayerCardState();
}

class __PlayerCardState extends State<_PlayerCard> {
  final TextEditingController _nameController = TextEditingController();
  int? _selectedAvatarIndex = null;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _selectedAvatarIndex != null
        ? 'assets/images/avatars/avatar_${_selectedAvatarIndex!.toString().padLeft(2, '0')}.png'
        : 'assets/images/avatars/avatar_unknown.png';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 81, 39, 180),
            Color.fromARGB(255, 106, 58, 201),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Card(
        color: Colors.transparent,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            spacing: 16.0,
            children: [
              Image.asset(avatarUrl, width: 80, height: 80),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: I18nKeys.instance.addPlayers.playerName.tr(),
                        labelStyle: const TextStyle(color: Colors.white),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5EDF), Color(0xFF6A5DFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(64),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFF3EDF,
                            ).withValues(alpha: 0.4),
                            blurRadius: 12.0,
                            spreadRadius: 0.5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          final selectedAvatar = await showModalBottomSheet<int>(
                            context: context,
                            useSafeArea: true,
                            backgroundColor: Colors.white,
                            isScrollControlled: false,
                            isDismissible: true,
                            builder: (context) => Scaffold(
                              body: Center(
                                child: GridView.builder(
                                  padding: EdgeInsets.all(20),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                      ),
                                  itemCount: 10,
                                  itemBuilder: (context, index) {
                                    final avatarIndex = index + 1;
                                    return GestureDetector(
                                      onTap: () {
                                        // Handle avatar selection
                                        Navigator.pop(context, avatarIndex);
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.asset(
                                          'assets/images/avatars/avatar_${avatarIndex.toString().padLeft(2, '0')}.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );

                          if (selectedAvatar != null) {
                            setState(() {
                              _selectedAvatarIndex = selectedAvatar;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 0.0,
                            vertical: 12.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(64),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: Text(
                            I18nKeys.instance.addPlayers.chooseAvatar.tr(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
            ],
          ),
        ),
      ),
    );
  }
}

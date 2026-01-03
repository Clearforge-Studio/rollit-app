import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rollit/widgets/add_players/avatar_utils.dart';

class DraftPlayerCard extends StatefulWidget {
  final GlobalKey avatarKey;
  final FocusNode focusNode;
  final bool autofocus;
  final Future<int?> Function(int? selectedAvatarIndex) onPickAvatar;
  final void Function(String name, int avatarIndex) onValidate;
  final VoidCallback onRemove;
  final String playerNameLabel;

  const DraftPlayerCard({
    super.key,
    required this.avatarKey,
    required this.focusNode,
    required this.autofocus,
    required this.onPickAvatar,
    required this.onValidate,
    required this.onRemove,
    required this.playerNameLabel,
  });

  @override
  State<DraftPlayerCard> createState() => _DraftPlayerCardState();
}

class _DraftPlayerCardState extends State<DraftPlayerCard> {
  static const _submitAnimationDelay = Duration(milliseconds: 120);
  static const _submitAnimationDuration = Duration(milliseconds: 280);
  late final TextEditingController _nameController;
  int? _selectedAvatarIndex;
  bool _isSubmitting = false;
  bool _collapse = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    if (widget.autofocus) {
      _requestFocus();
    }
  }

  @override
  void didUpdateWidget(covariant DraftPlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autofocus && !oldWidget.autofocus) {
      _requestFocus();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _requestFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isSubmitting) return;
      FocusScope.of(context).requestFocus(widget.focusNode);
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    HapticFeedback.lightImpact();
    final avatarIndex = _selectedAvatarIndex ?? 0;
    widget.onValidate(_nameController.text.trim(), avatarIndex);
    await Future.delayed(_submitAnimationDelay);
    if (!mounted) {
      return;
    }
    setState(() {
      _collapse = true;
    });
    await Future.delayed(_submitAnimationDuration);
    if (mounted) {
      widget.onRemove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = avatarAssetForIndex(_selectedAvatarIndex);
    final canValidate = _nameController.text.trim().isNotEmpty;

    final cardContent = Container(
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
            children: [
              GestureDetector(
                onTap: _isSubmitting
                    ? null
                    : () async {
                        final selectedAvatar = await widget.onPickAvatar(
                          _selectedAvatarIndex,
                        );
                        if (selectedAvatar != null) {
                          setState(() {
                            _selectedAvatarIndex = selectedAvatar;
                          });
                        }
                      },
                child: ClipRRect(
                  key: widget.avatarKey,
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(avatarUrl, width: 80, height: 80),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  controller: _nameController,
                  autofocus: widget.autofocus,
                  focusNode: widget.focusNode,
                  enabled: !_isSubmitting,
                  decoration: InputDecoration(
                    labelText: widget.playerNameLabel,
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      onPressed: _isSubmitting ? null : widget.onRemove,
                      icon: const Icon(Icons.close),
                      color: Colors.white,
                      disabledColor: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      onPressed: canValidate && !_isSubmitting ? _submit : null,
                      icon: const Icon(Icons.check),
                      color: Colors.white,
                      disabledColor: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return AnimatedOpacity(
      duration: _submitAnimationDuration,
      opacity: _collapse ? 0.0 : 1.0,
      child: AnimatedSize(
        duration: _submitAnimationDuration,
        curve: Curves.easeInOut,
        child: _collapse ? const SizedBox.shrink() : cardContent,
      ),
    );
  }
}

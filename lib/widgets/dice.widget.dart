import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rollit/models/category.model.dart';

class Dice extends StatefulWidget {
  final List<DiceCategory> categories;
  final double size;
  final ValueChanged<DiceCategory> onRollComplete;
  final Function? onRollStart;
  final bool hideDiceOnComplete;
  final bool hideDiceInitially;
  final String diceText;

  /// Face par défaut (avant le premier roll)
  final String initialFacePath;

  const Dice({
    super.key,
    required this.categories,
    required this.onRollComplete,
    this.onRollStart,
    required this.initialFacePath,
    this.hideDiceOnComplete = false,
    this.hideDiceInitially = false,
    this.diceText = "Roll!",
    this.size = 150,
  });

  @override
  State<Dice> createState() => _DiceState();
}

class _DiceState extends State<Dice> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _spin;
  bool _hideDice = false;

  int _currentLogicalIndex = -1; // -1 → on n’a pas encore roll

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _spin = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    if (widget.hideDiceInitially) {
      _hideDice = true;
    }
  }

  void roll() {
    Future.microtask(() {
      if (widget.onRollStart != null) {
        widget.onRollStart!();
      }
    });

    final total = widget.categories.length;
    final newIndex = Random().nextInt(total);

    setState(() => _currentLogicalIndex = newIndex);

    _controller.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (widget.hideDiceOnComplete) {
        setState(() => _hideDice = true);
      }

      widget.onRollComplete(widget.categories[newIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayedImage = _currentLogicalIndex == -1
        ? widget.initialFacePath
        : widget.categories[_currentLogicalIndex].imagePath;

    return GestureDetector(
      onTap: roll,
      child: AnimatedBuilder(
        animation: _spin,
        builder: (_, child) {
          final angle = _spin.value * pi * 2;
          final scale = 1.0 + sin(_spin.value * pi) * 0.15;

          return Column(
            children: [
              if (!_hideDice)
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..rotateZ(angle)
                    ..scale(scale),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: FittedBox(child: Image.asset(displayedImage)),
                  ),
                ),

              if (!_hideDice) const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _hideDice = false;
                  });
                  roll();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 64,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF5EDF), // rose neon
                        Color(0xFF6A5DFF), // violet RollIt!
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(64),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF3EDF).withValues(alpha: 0.4),
                        blurRadius: 22,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.diceText,
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

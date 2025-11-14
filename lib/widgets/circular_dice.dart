import 'dart:math';
import 'package:flutter/material.dart';

class CircularDice extends StatefulWidget {
  final List<String> faces;
  final Function(int faceIndex) onRollComplete;
  final double size;

  const CircularDice({
    super.key,
    required this.faces,
    required this.onRollComplete,
    this.size = 160,
  });

  @override
  State<CircularDice> createState() => _CircularDiceState();
}

class _CircularDiceState extends State<CircularDice>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _tilt;
  late Animation<double> _scale;
  int _currentFace = 0;
  bool _isRolling = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _tilt = Tween<double>(
      begin: 0,
      end: 0.18,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scale = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onRollComplete(_currentFace);
        setState(() => _isRolling = false);
      }
    });
  }

  void roll() {
    if (_isRolling) return;

    setState(() => _isRolling = true);

    _controller.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _currentFace = Random().nextInt(widget.faces.length);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: roll,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          final tiltX = sin(_tilt.value) * 0.2;
          final tiltY = cos(_tilt.value) * 0.2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateX(tiltX)
              ..rotateY(tiltY)
              ..rotateZ(_rotation.value)
              ..scale(_scale.value),
            child: child,
          );
        },
        child: Container(
          height: widget.size,
          width: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFA47BFF), Color(0xFF6A5DFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purpleAccent.withOpacity(0.4),
                blurRadius: 25,
                spreadRadius: 2,
              ),
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Image.asset(widget.faces[_currentFace], fit: BoxFit.contain),
        ),
      ),
    );
  }
}

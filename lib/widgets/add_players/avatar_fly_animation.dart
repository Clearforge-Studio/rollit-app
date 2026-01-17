import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rollit/widgets/add_players/avatar_utils.dart';

void animateAvatarToGrid({
  required BuildContext context,
  required TickerProvider vsync,
  required GlobalKey fromKey,
  required GlobalKey toKey,
  required int avatarIndex,
  required String name,
  required VoidCallback onComplete,
}) {
  final overlay = Overlay.of(context);
  final fromBox = fromKey.currentContext?.findRenderObject() as RenderBox?;
  final toBox = toKey.currentContext?.findRenderObject() as RenderBox?;
  if (fromBox == null || toBox == null) {
    return;
  }

  final fromOffset = fromBox.localToGlobal(Offset.zero);
  final toOffset = toBox.localToGlobal(Offset.zero);
  final fromSize = fromBox.size;
  final toSize = toBox.size;
  final avatarUrl = avatarAssetForIndex(avatarIndex);

  final controller = AnimationController(
    vsync: vsync,
    duration: const Duration(milliseconds: 450),
  );
  final animation = CurvedAnimation(
    parent: controller,
    curve: Curves.easeInOutCubic,
  );

  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        final left = lerpDouble(fromOffset.dx, toOffset.dx, t) ?? 0;
        final top = lerpDouble(fromOffset.dy, toOffset.dy, t) ?? 0;
        final width = lerpDouble(fromSize.width, toSize.width, t) ?? 0;
        final height = lerpDouble(fromSize.height, toSize.height, t) ?? 0;
        return Positioned(
          left: left,
          top: top,
          child: IgnorePointer(
            child: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(avatarUrl, width: width, height: height),
                    const SizedBox(height: 6),
                    Opacity(
                      opacity: t,
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  overlay.insert(entry);
  controller.forward().whenComplete(() {
    entry.remove();
    controller.dispose();
    onComplete();
  });
}

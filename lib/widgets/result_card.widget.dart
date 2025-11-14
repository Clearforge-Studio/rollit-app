import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final String? title;
  final Widget? icon;
  final String? actionText;

  const ResultCard({
    super.key,
    required this.title,
    required this.icon,
    required this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.all(26),
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.45,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3F147C), // violet intense
            Color(0xFF2A0D56),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        // glow externe
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B2CFF).withValues(alpha: 0.55),
            blurRadius: 35,
            spreadRadius: 2,
          ),
        ],

        // contour néon
        border: Border.all(color: const Color(0xFF7F3DFF), width: 3),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- TITRE ---
            Text(
              title?.toUpperCase() ?? '',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFFE148), // jaune pastel
                letterSpacing: 1.1,
              ),
            ),

            const SizedBox(height: 28),

            // --- ICON EMBOSSED ---
            Container(
              width: 110,
              height: 110,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6B2FE5), Color(0xFF3C167D)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    colors: [Color(0xFFB9A7FF), Color(0xFF7D52E0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(rect);
                },
                blendMode: BlendMode.srcATop,
                child: icon,
              ),
            ),

            const SizedBox(height: 30),

            // --- TEXTE D’ACTION ---
            Text(
              actionText ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

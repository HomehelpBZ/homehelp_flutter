import 'package:flutter/material.dart';

// ── Hero illustration — Ethiopian home with family ────────────────────────────
class HeroIllustration extends StatelessWidget {
  const HeroIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: CustomPaint(
        size: const Size(double.infinity, 200),
        painter: _HeroPainter(),
      ),
    );
  }
}

class _HeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky gradient background
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.05),
          Colors.white.withOpacity(0.12),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // Ground
    final groundPaint = Paint()
      ..color = Colors.white.withOpacity(0.08);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.75, w, h * 0.25), groundPaint);

    // House body
    final housePaint = Paint()..color = Colors.white.withOpacity(0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.25, h * 0.4, w * 0.5, h * 0.35),
        const Radius.circular(4),
      ),
      housePaint,
    );

    // Roof
    final roofPaint = Paint()..color = Colors.white;
    final roofPath = Path();
    roofPath.moveTo(w * 0.18, h * 0.42);
    roofPath.lineTo(w * 0.5, h * 0.15);
    roofPath.lineTo(w * 0.82, h * 0.42);
    roofPath.close();
    canvas.drawPath(roofPath, roofPaint);

    // Door
    final doorPaint = Paint()..color = const Color(0xFF1A237E).withOpacity(0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.44, h * 0.58, w * 0.12, h * 0.17),
        const Radius.circular(3),
      ),
      doorPaint,
    );

    // Windows
    final windowPaint = Paint()
      ..color = const Color(0xFF1565C0).withOpacity(0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.29, h * 0.5, w * 0.1, h * 0.1),
        const Radius.circular(2),
      ),
      windowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.61, h * 0.5, w * 0.1, h * 0.1),
        const Radius.circular(2),
      ),
      windowPaint,
    );

    // Stars/sparkles
    final starPaint = Paint()..color = Colors.white.withOpacity(0.6);
    _drawStar(canvas, Offset(w * 0.1, h * 0.15), 4, starPaint);
    _drawStar(canvas, Offset(w * 0.85, h * 0.1), 3, starPaint);
    _drawStar(canvas, Offset(w * 0.92, h * 0.3), 2, starPaint);
    _drawStar(canvas, Offset(w * 0.08, h * 0.4), 2.5, starPaint);

    // People silhouettes
    final peoplePaint = Paint()..color = Colors.white.withOpacity(0.85);
    // Person 1
    canvas.drawCircle(Offset(w * 0.15, h * 0.62), 8, peoplePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.115, h * 0.68, 15, 20),
        const Radius.circular(4),
      ),
      peoplePaint,
    );
    // Person 2
    canvas.drawCircle(Offset(w * 0.85, h * 0.62), 8, peoplePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.815, h * 0.68, 15, 20),
        const Radius.circular(4),
      ),
      peoplePaint,
    );

    // Trees
    final treePaint = Paint()..color = Colors.white.withOpacity(0.4);
    _drawTree(canvas, Offset(w * 0.05, h * 0.75), treePaint);
    _drawTree(canvas, Offset(w * 0.95, h * 0.75), treePaint);

    // Verified shield badge
    final shieldPaint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.9);
    final shieldPath = Path();
    final sx = w * 0.72;
    final sy = h * 0.2;
    shieldPath.moveTo(sx, sy);
    shieldPath.lineTo(sx + 18, sy + 6);
    shieldPath.lineTo(sx + 18, sy + 18);
    shieldPath.quadraticBezierTo(sx + 18, sy + 26, sx, sy + 30);
    shieldPath.quadraticBezierTo(sx - 18, sy + 26, sx - 18, sy + 18);
    shieldPath.lineTo(sx - 18, sy + 6);
    shieldPath.close();
    canvas.drawPath(shieldPath, shieldPaint);

    // Check mark in shield
    final checkPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final checkPath = Path();
    checkPath.moveTo(sx - 7, sy + 16);
    checkPath.lineTo(sx - 2, sy + 21);
    checkPath.lineTo(sx + 8, sy + 11);
    canvas.drawPath(checkPath, checkPaint);
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawCircle(center, size, paint);
  }

  void _drawTree(Canvas canvas, Offset base, Paint paint) {
    final treePath = Path();
    treePath.moveTo(base.dx, base.dy);
    treePath.lineTo(base.dx - 12, base.dy);
    treePath.lineTo(base.dx, base.dy - 30);
    treePath.close();
    canvas.drawPath(treePath, paint);
    final treePath2 = Path();
    treePath2.moveTo(base.dx, base.dy - 15);
    treePath2.lineTo(base.dx - 16, base.dy - 15);
    treePath2.lineTo(base.dx, base.dy - 50);
    treePath2.close();
    canvas.drawPath(treePath2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── How it works illustration ─────────────────────────────────────────────────
class HowItWorksIllustration extends StatelessWidget {
  final int step; // 1, 2, or 3
  const HowItWorksIllustration({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56, height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        step == 1
            ? Icons.search
            : step == 2
                ? Icons.verified_user_outlined
                : Icons.handshake_outlined,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}

// ── Trust illustration ────────────────────────────────────────────────────────
class TrustIllustration extends StatelessWidget {
  const TrustIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _TrustItem(
            icon: Icons.badge_outlined,
            label: 'Fayda ID',
            color: const Color(0xFF1A237E),
          ),
          const SizedBox(width: 8),
          Container(
            width: 2,
            height: 60,
            color: Colors.grey[200],
          ),
          const SizedBox(width: 8),
          _TrustItem(
            icon: Icons.people_outline,
            label: 'Guarantor',
            color: const Color(0xFF1565C0),
          ),
          const SizedBox(width: 8),
          Container(
            width: 2,
            height: 60,
            color: Colors.grey[200],
          ),
          const SizedBox(width: 8),
          _TrustItem(
            icon: Icons.star_outline,
            label: 'Reviewed',
            color: const Color(0xFF283593),
          ),
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _TrustItem(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
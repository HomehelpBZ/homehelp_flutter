import 'package:flutter/material.dart';
import '../l10n/language_provider.dart';

// ── Hero illustration — Ethiopian home ───────────────────────────────────────
class HeroIllustration extends StatelessWidget {
  const HeroIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: CustomPaint(
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

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.75, w, h * 0.25),
      Paint()..color = Colors.white.withOpacity(0.08),
    );

    // House body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.25, h * 0.4, w * 0.5, h * 0.35),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white.withOpacity(0.9),
    );

    // Roof
    final roofPath = Path()
      ..moveTo(w * 0.18, h * 0.42)
      ..lineTo(w * 0.5, h * 0.12)
      ..lineTo(w * 0.82, h * 0.42)
      ..close();
    canvas.drawPath(roofPath, Paint()..color = Colors.white);

    // Door
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.44, h * 0.58, w * 0.12, h * 0.17),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF1A237E).withOpacity(0.6),
    );

    // Windows
    final winPaint = Paint()..color = const Color(0xFF1565C0).withOpacity(0.5);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.29, h * 0.5, w * 0.1, h * 0.1),
            const Radius.circular(2)),
        winPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.61, h * 0.5, w * 0.1, h * 0.1),
            const Radius.circular(2)),
        winPaint);

    // Stars
    final starPaint = Paint()..color = Colors.white.withOpacity(0.6);
    for (final pos in [
      Offset(w * 0.1, h * 0.15),
      Offset(w * 0.85, h * 0.1),
      Offset(w * 0.92, h * 0.3),
      Offset(w * 0.08, h * 0.4),
    ]) {
      canvas.drawCircle(pos, 3, starPaint);
    }

    // People
    final peoplePaint = Paint()..color = Colors.white.withOpacity(0.85);
    for (final x in [w * 0.15, w * 0.85]) {
      canvas.drawCircle(Offset(x, h * 0.62), 8, peoplePaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x - 7.5, h * 0.68, 15, 20),
            const Radius.circular(4)),
        peoplePaint,
      );
    }

    // Trees
    final treePaint = Paint()..color = Colors.white.withOpacity(0.4);
    for (final x in [w * 0.05, w * 0.95]) {
      final base = Offset(x, h * 0.75);
      canvas.drawPath(
        Path()
          ..moveTo(base.dx, base.dy)
          ..lineTo(base.dx - 12, base.dy)
          ..lineTo(base.dx, base.dy - 30)
          ..close(),
        treePaint,
      );
    }

    // Verified shield
    final shieldPath = Path();
    final sx = w * 0.72;
    final sy = h * 0.18;
    shieldPath
      ..moveTo(sx, sy)
      ..lineTo(sx + 18, sy + 6)
      ..lineTo(sx + 18, sy + 18)
      ..quadraticBezierTo(sx + 18, sy + 26, sx, sy + 30)
      ..quadraticBezierTo(sx - 18, sy + 26, sx - 18, sy + 18)
      ..lineTo(sx - 18, sy + 6)
      ..close();
    canvas.drawPath(shieldPath,
        Paint()..color = const Color(0xFF4CAF50).withOpacity(0.9));
    final checkPath = Path()
      ..moveTo(sx - 7, sy + 16)
      ..lineTo(sx - 2, sy + 21)
      ..lineTo(sx + 8, sy + 11);
    canvas.drawPath(
        checkPath,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── How it works illustration ─────────────────────────────────────────────────
class HowItWorksIllustration extends StatelessWidget {
  const HowItWorksIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StepIcon(
            icon: Icons.search,
            label: '1',
            color: const Color(0xFF1A237E),
          ),
          _Arrow(),
          _StepIcon(
            icon: Icons.verified_user_outlined,
            label: '2',
            color: const Color(0xFF1565C0),
          ),
          _Arrow(),
          _StepIcon(
            icon: Icons.handshake_outlined,
            label: '3',
            color: const Color(0xFF283593),
          ),
        ],
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StepIcon(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
      const SizedBox(height: 6),
      Container(
        width: 20, height: 20,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ),
      ),
    ]);
  }
}

class _Arrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(Icons.arrow_forward,
        color: const Color(0xFF1A237E).withOpacity(0.3), size: 20);
  }
}

// ── Trust illustration ────────────────────────────────────────────────────────
class TrustIllustration extends StatelessWidget {
  const TrustIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TrustBadge(
            icon: Icons.badge_outlined,
            label: s.trustBadgeFayda,
            color: const Color(0xFF1A237E),
          ),
          _VerticalDivider(),
          _TrustBadge(
            icon: Icons.people_outline,
            label: s.trustBadgeGuarantor,
            color: const Color(0xFF1565C0),
          ),
          _VerticalDivider(),
          _TrustBadge(
            icon: Icons.star_outline,
            label: s.trustBadgeReviewed,
            color: const Color(0xFF283593),
          ),
        ],
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _TrustBadge(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Icon(icon, color: color, size: 26),
      ),
      const SizedBox(height: 6),
      Text(label,
          style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600)),
    ]);
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 50, color: Colors.grey[200]);
  }
}

// ── Housekeeper illustration ──────────────────────────────────────────────────
class HousekeeperIllustration extends StatelessWidget {
  const HousekeeperIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ProfileCard(initials: 'TK', name: 'Tigist K.', area: s.isAmharic ? 'ቦሌ' : 'Bole', verifiedLabel: s.verified),
          const SizedBox(width: 12),
          _ProfileCard(initials: 'BZ', name: 'Betty Z.', area: s.isAmharic ? 'ቂርቆስ' : 'Kirkos', verifiedLabel: s.verified),
          const SizedBox(width: 12),
          _ProfileCard(initials: 'MA', name: 'Marta A.', area: s.isAmharic ? 'የካ' : 'Yeka', verifiedLabel: s.verified),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String initials;
  final String name;
  final String area;
  final String verifiedLabel;
  const _ProfileCard(
      {required this.initials, required this.name, required this.area, required this.verifiedLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withOpacity(0.9),
            child: Text(initials,
                style: const TextStyle(
                    color: Color(0xFF1A237E),
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 6),
          Text(name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
          Text(area,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 9),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.verified_user, size: 8, color: Colors.greenAccent),
            const SizedBox(width: 2),
            Text(verifiedLabel,
                style: TextStyle(
                    color: Colors.greenAccent.withOpacity(0.9),
                    fontSize: 8)),
          ]),
        ],
      ),
    );
  }
}

// ── Addis Ababa skyline illustration ─────────────────────────────────────────
class AddisSkylinesIllustration extends StatelessWidget {
  const AddisSkylinesIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: CustomPaint(painter: _SkylinePainter()),
    );
  }
}

class _SkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = const Color(0xFF1A237E).withOpacity(0.15);

    // Buildings of various heights
    final buildings = [
      [0.0, 0.4, 0.06, 1.0],
      [0.07, 0.2, 0.05, 1.0],
      [0.13, 0.5, 0.08, 1.0],
      [0.22, 0.15, 0.06, 1.0],
      [0.29, 0.35, 0.07, 1.0],
      [0.37, 0.6, 0.09, 1.0],
      [0.47, 0.25, 0.06, 1.0],
      [0.54, 0.45, 0.08, 1.0],
      [0.63, 0.3, 0.07, 1.0],
      [0.71, 0.55, 0.06, 1.0],
      [0.78, 0.2, 0.05, 1.0],
      [0.84, 0.4, 0.08, 1.0],
      [0.93, 0.3, 0.07, 1.0],
    ];

    for (final b in buildings) {
      canvas.drawRect(
        Rect.fromLTWH(
            w * b[0], h * b[1], w * b[2], h * b[3]),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
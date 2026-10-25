import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';

class MapCanvas extends StatelessWidget {
  const MapCanvas({
    super.key,
    this.route = false,
    this.members = false,
    this.onMember,
  });
  final bool route, members;
  final ValueChanged<int>? onMember;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) => Stack(
      fit: StackFit.expand,
      children: [
        const Art('map.png', fit: BoxFit.cover),
        CustomPaint(
          painter: _RoutePainter(active: route, members: members),
        ),
        if (!route)
          Align(
            alignment: const Alignment(0, -.04),
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Palette.pink.withValues(alpha: .17),
                    Palette.pink.withValues(alpha: 0),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Palette.background,
                    border: Border.all(color: Palette.pink, width: 3),
                  ),
                ),
              ),
            ),
          ),
        if (members)
          for (int i = 0; i < 4; i++)
            Positioned(
              left: bounds.maxWidth * [.2, .7, .25, .46][i],
              top: bounds.maxHeight * [.11, .16, .45, .74][i],
              child: GestureDetector(
                onTap: () => onMember?.call(i),
                child: Semantics(
                  button: true,
                  label: 'View member ${i + 1}',
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: [
                        Palette.yellow,
                        Palette.green,
                        Palette.pink,
                        Palette.yellow,
                      ][i],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                    ),
                    child: Avatar(
                      image: 'avatars/avatar${i == 0 ? '' : i}.png',
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
      ],
    ),
  );
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter({required this.active, required this.members});
  final bool active, members;
  @override
  void paint(Canvas canvas, Size size) {
    if (!active && !members) return;
    final points = [
      const Offset(.5, .48),
      const Offset(.41, .38),
      const Offset(.66, .3),
      const Offset(.62, .22),
      const Offset(.7, .21),
      const Offset(.62, .09),
    ];
    final paint = Paint()
      ..color = Palette.pink
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    void dotted(List<Offset> points, Color color) {
      paint.color = color;
      for (int i = 1; i < points.length; i++) {
        final a = Offset(
          points[i - 1].dx * size.width,
          points[i - 1].dy * size.height,
        );
        final b = Offset(points[i].dx * size.width, points[i].dy * size.height);
        final steps = math.max(1, (b - a).distance ~/ 8);
        for (int j = 0; j <= steps; j++) {
          canvas.drawCircle(Offset.lerp(a, b, j / steps)!, 1.6, paint);
        }
      }
    }

    dotted(points, Palette.pink);
    if (members) {
      dotted([
        const Offset(.2, .16),
        const Offset(.08, .2),
        const Offset(.18, .25),
        const Offset(.41, .21),
        const Offset(.31, .08),
      ], Palette.yellow);
      dotted([
        const Offset(.7, .2),
        const Offset(.41, .27),
        const Offset(.52, .36),
        const Offset(.7, .32),
      ], Palette.green);
      dotted([
        const Offset(.25, .48),
        const Offset(.18, .53),
        const Offset(.38, .8),
        const Offset(.46, .78),
      ], Palette.blue);
    }
  }

  @override
  bool shouldRepaint(_RoutePainter old) =>
      active != old.active || members != old.members;
}

class FriendStrip extends StatelessWidget {
  const FriendStrip({super.key, this.onTap});
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => GlassPanel(
    onTap: onTap,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    gradient: LinearGradient(
      colors: [
        const Color(0xFF6D7295).withValues(alpha: .92),
        const Color(0xFF292746).withValues(alpha: .94),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 42,
            child: Stack(
              children: [
                for (int i = 0; i < 6; i++)
                  Positioned(
                    left: i * 24,
                    child: Avatar(
                      image: 'avatars/avatar${i == 0 ? '' : i}.png',
                      size: 42,
                    ),
                  ),
                const Positioned(
                  left: 144,
                  child: CircleAvatar(
                    radius: 21,
                    backgroundColor: Palette.panel,
                    child: Text(
                      '+8',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        IconCircle(
          icon: Icons.center_focus_strong_rounded,
          label: 'Open club map',
          size: 44,
          gradient: Palette.heading,
          onTap: onTap ?? () => Navigator.pushNamed(context, '/map'),
        ),
      ],
    ),
  );
}

class ClubMapScreen extends StatefulWidget {
  const ClubMapScreen({super.key});
  @override
  State<ClubMapScreen> createState() => _ClubMapScreenState();
}

class _ClubMapScreenState extends State<ClubMapScreen> {
  int? selected;
  final transform = TransformationController();
  @override
  void dispose() {
    transform.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: InteractiveViewer(
            transformationController: transform,
            minScale: 1,
            maxScale: 2.5,
            child: MapCanvas(
              members: true,
              onMember: (i) => setState(() => selected = i),
            ),
          ),
        ),
        const Positioned(
          top: 0,
          left: 0,
          child: SafeArea(
            child: Padding(padding: EdgeInsets.all(16), child: BackCircle()),
          ),
        ),
        const Positioned(
          top: 70,
          right: 16,
          child: Chip(
            label: Text('Demo map', style: TextStyle(fontSize: 11)),
            visualDensity: VisualDensity.compact,
          ),
        ),
        Positioned(
          right: 20,
          bottom: selected == null ? 125 : 235,
          child: IconCircle(
            icon: Icons.my_location_rounded,
            label: 'Recenter map',
            onTap: () => transform.value = Matrix4.identity(),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 24,
          child: SafeArea(
            top: false,
            child: selected == null
                ? FriendStrip(onTap: () => setState(() => selected = 0))
                : GlassPanel(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Avatar(
                              image:
                                  'avatars/avatar${selected == 0 ? '' : selected}.png',
                              size: 52,
                              ring: true,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    [
                                      'Tatiana Kenter',
                                      'Chance Holt',
                                      'Eliza Nichols',
                                      'Alex Morgan',
                                    ][selected!],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    'Cycling · 10.8 km',
                                    style: TextStyle(color: Palette.muted),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Close member',
                              onPressed: () => setState(() => selected = null),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        PrimaryButton(
                          'View Profile',
                          compact: true,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/member'),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    ),
  );
}

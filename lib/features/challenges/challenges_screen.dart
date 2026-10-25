import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});
  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  int filter = 0;
  void open(BuildContext context, String id) {
    Navigator.pushNamed(
      context,
      id == 'cycling' ? '/activity' : '/workout',
      arguments: id == 'cycling' ? ActivityKind.cycling : id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final items = challengeItems
        .where((item) => app.completed.contains(item.id) == (filter == 1))
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 25),
      children: [
        Row(
          children: [
            const Expanded(child: GradientText('Challenges', size: 29)),
            Segment(
              labels: const ['Do', 'Done'],
              index: filter,
              onChanged: (i) => setState(() => filter = i),
            ),
          ],
        ),
        const SizedBox(height: 30),
        const Row(
          children: [
            Art('challenges/medal.png', width: 23, height: 32),
            SizedBox(width: 9),
            Text(
              'Daily Mission',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            for (int i = 0; i < 2; i++) ...[
              if (i == 1) const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      open(context, i == 0 ? 'build-abs' : 'fat-burning'),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 145,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Art('challenges/pic${i + 1}.png', fit: BoxFit.cover),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Color(0xFF3C3E68)],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 10,
                            bottom: 12,
                            right: 10,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        i == 0 ? '10 workout' : '30 min',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        i == 0 ? 'Build ABS' : 'Fat Burning',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CustomPaint(
                                    painter: RingPainter(
                                      progress:
                                          app.completed.contains(
                                            i == 0
                                                ? 'build-abs'
                                                : 'fat-burning',
                                          )
                                          ? 1
                                          : .35,
                                      stroke: 3,
                                      color: i == 0
                                          ? Palette.pink
                                          : Palette.purple,
                                    ),
                                    child:
                                        app.completed.contains(
                                          i == 0 ? 'build-abs' : 'fat-burning',
                                        )
                                        ? const Icon(
                                            Icons.done_all_rounded,
                                            size: 18,
                                          )
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 38),
        SectionTitle(filter == 0 ? 'More Challenges' : 'Completed Challenges'),
        const SizedBox(height: 24),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                const Icon(
                  Icons.task_alt_rounded,
                  size: 45,
                  color: Palette.muted,
                ),
                const SizedBox(height: 16),
                Text(
                  filter == 0
                      ? 'All challenges complete. Well done!'
                      : 'Your next achievement is waiting.',
                  style: const TextStyle(color: Palette.muted),
                ),
              ],
            ),
          ),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(left: 36, bottom: 16),
            child: GlassPanel(
              padding: const EdgeInsets.fromLTRB(9, 9, 15, 9),
              onTap: () => showModalBottomSheet<void>(
                context: context,
                backgroundColor: Palette.background,
                builder: (_) => Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Art(
                        'challenges/${item.image}.png',
                        width: 60,
                        height: 60,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${item.minutes} minute target · all levels',
                        style: const TextStyle(color: Palette.muted),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        'Start Challenge',
                        onPressed: () {
                          Navigator.pop(context);
                          open(context, item.id);
                        },
                      ),
                      if (filter == 0)
                        TextButton(
                          onPressed: () {
                            app.complete(item.id);
                            Navigator.pop(context);
                          },
                          child: const Text('I’ve completed this today'),
                        ),
                    ],
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Palette.background.withValues(alpha: .25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Art('challenges/${item.image}.png'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    filter == 0 ? Icons.timer_outlined : Icons.task_alt_rounded,
                    size: 19,
                    color: filter == 0 ? Palette.muted : Palette.green,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${item.minutes} min',
                    style: const TextStyle(color: Palette.muted, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

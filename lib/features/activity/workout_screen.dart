import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/session_clock.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key, this.challengeId});
  final String? challengeId;
  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final clock = SessionClock();
  int exercise = 0;
  bool completed = false;
  List<(String, String, int)> get exercises => switch (widget.challengeId) {
    'yoga' => [
      ('Mountain Pose', 'Workoutimg.png', 30),
      ('Gentle Stretch', 'Workoutimg2.png', 45),
      ('Rest & Breathe', 'Workoutimg.png', 30),
    ],
    'meditation' => [
      ('Breathe In', 'Workoutimg.png', 30),
      ('Find Your Calm', 'Workoutimg2.png', 45),
      ('Breathe Out', 'Workoutimg.png', 30),
    ],
    _ => [
      ('Plank', 'Workoutimg.png', 30),
      ('Cross Crunches', 'Workoutimg2.png', 45),
      ('Plank Hold', 'Workoutimg.png', 30),
    ],
  };
  @override
  void initState() {
    super.initState();
    clock.addListener(onTick);
    clock.start();
  }

  void onTick() {
    if (clock.running && clock.seconds >= exercises[exercise].$3) clock.pause();
  }

  @override
  void dispose() {
    clock.removeListener(onTick);
    clock.dispose();
    super.dispose();
  }

  Future<void> next() async {
    clock.pause();
    if (exercise < exercises.length - 1) {
      setState(() => exercise++);
      clock.reset();
      clock.start();
    } else {
      await AppScope.of(context).complete(widget.challengeId ?? 'build-abs');
      if (mounted) setState(() => completed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (completed) {
      return PageFrame(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Art('challenges/medal.png', width: 140, height: 170),
              const SizedBox(height: 28),
              const GradientText('Workout Complete!', size: 32),
              const SizedBox(height: 15),
              const Text(
                'A stronger you, one session at a time.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Palette.muted, fontSize: 16),
              ),
              const SizedBox(height: 35),
              PrimaryButton('Done', onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      );
    }
    return PageFrame(
      trailing: GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        radius: 30,
        child: Row(
          children: [
            const Icon(Icons.timer_outlined, size: 20),
            const SizedBox(width: 7),
            Text(
              '0${exercise + 1} / 03',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      child: ListenableBuilder(
        listenable: clock,
        builder: (context, _) {
          final item = exercises[exercise];
          final left = math.max(0, item.$3 - clock.seconds);
          return LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: AspectRatio(
                        aspectRatio: 1.5,
                        child: Art('workout/${item.$2}', fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      item.$1,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 230,
                      height: 245,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          SizedBox(
                            width: 230,
                            height: 230,
                            child: CustomPaint(
                              painter: RingPainter(
                                progress: left / item.$3,
                                color: Palette.purple,
                                stroke: 11,
                                start: math.pi * .72,
                                sweep: math.pi * 1.56,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 78,
                            child: Text(
                              clockText(left),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 5,
                            child: IconCircle(
                              key: const ValueKey('workout-toggle'),
                              icon: clock.running
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              label: clock.running
                                  ? 'Pause workout'
                                  : 'Resume workout',
                              size: 80,
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFA09AD1),
                                  Color(0xFF4973CE),
                                  Color(0xFF46B7C1),
                                ],
                              ),
                              onTap: () {
                                if (clock.running) {
                                  clock.pause();
                                } else if (left > 0) {
                                  clock.start();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GlassPanel(
                        padding: const EdgeInsets.all(7),
                        radius: 17,
                        onTap: next,
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Art(
                                'workout/${exercises[(exercise + 1) % exercises.length].$2}',
                                width: 55,
                                height: 55,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise < 2 ? 'Next:' : 'You did it!',
                                    style: const TextStyle(
                                      color: Palette.muted,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    exercise < 2
                                        ? exercises[exercise + 1].$1
                                        : 'Finish Workout',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              key: const ValueKey('next-exercise'),
                              tooltip: exercise < 2
                                  ? 'Next exercise'
                                  : 'Finish workout',
                              onPressed: next,
                              icon: const Icon(
                                Icons.chevron_right_rounded,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

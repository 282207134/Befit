import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_controller.dart';
import '../../core/session_clock.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../club/map_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, this.kind});
  final Object? kind;
  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final clock = SessionClock();
  bool started = false, saving = false;
  ActivityKind get kind => widget.kind is ActivityKind
      ? widget.kind! as ActivityKind
      : ActivityKind.cycling;
  @override
  void dispose() {
    clock.dispose();
    super.dispose();
  }

  Future<void> finish() async {
    clock.pause();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF292640),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Finish your activity?'),
        content: const Text(
          'Your session will be saved to your activity history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Going'),
          ),
          TextButton(
            key: const ValueKey('confirm-finish'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finish & Save'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true || saving) return;
    setState(() => saving = true);
    final seconds = math.max(1, clock.seconds);
    final app = AppScope.of(context);
    await app.addActivity(
      ActivityRecord(
        kind: kind,
        seconds: seconds,
        distance: kind.speed * seconds / 3600,
        date: app.now(),
      ),
    );
    if (mounted) Navigator.pushReplacementNamed(context, '/congratulations');
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !started || saving,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) finish();
    },
    child: Scaffold(
      body: ListenableBuilder(
        listenable: clock,
        builder: (context, _) => Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(child: MapCanvas(route: started)),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconCircle(
                        icon: Icons.chevron_left_rounded,
                        label: 'Back',
                        onTap: () {
                          if (started) {
                            finish();
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Palette.background.withValues(alpha: .7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Demo activity',
                          style: TextStyle(color: Palette.muted, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 32,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!started) GradientText('Start ${kind.label}', size: 32),
                    if (started)
                      GlassPanel(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        gradient: LinearGradient(
                          colors: [
                            Palette.background.withValues(alpha: .9),
                            Palette.panel.withValues(alpha: .8),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  (kind.speed * clock.seconds / 3600)
                                      .toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const Text(
                                  ' km',
                                  style: TextStyle(color: Palette.muted),
                                ),
                              ],
                            ),
                            Text(
                              clockText(clock.seconds),
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (started && !clock.running)
                      const Padding(
                        padding: EdgeInsets.only(top: 18),
                        child: Text(
                          'Activity Paused',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (started && !clock.running) ...[
                          IconCircle(
                            icon: Icons.stop_rounded,
                            label: 'Finish activity',
                            size: 65,
                            onTap: saving ? () {} : finish,
                          ),
                          const SizedBox(width: 25),
                        ],
                        IconCircle(
                          key: const ValueKey('activity-toggle'),
                          icon: clock.running
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          label: clock.running
                              ? 'Pause activity'
                              : started
                              ? 'Resume activity'
                              : 'Start activity',
                          size: 76,
                          gradient: Palette.heading,
                          onTap: () {
                            if (clock.running) {
                              clock.pause();
                            } else {
                              setState(() => started = true);
                              clock.start();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!started)
                      const Text(
                        'Simulated route & distance · no GPS required',
                        style: TextStyle(fontSize: 12, color: Palette.muted),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class CongratulationsScreen extends StatelessWidget {
  const CongratulationsScreen({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    back: false,
    child: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 290,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Art('confetti.png', width: 340),
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Palette.yellow.withValues(alpha: .14),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const Art('trophy.png', width: 205, height: 230),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const GradientText('Congratulations!', size: 34),
              const SizedBox(height: 20),
              const Text(
                'Every move is a step forward.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your activity has been saved.\nTake a breath. You’ve earned it.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Palette.muted,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  'View Results',
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/result'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
  );
}

class ActivityResultScreen extends StatelessWidget {
  const ActivityResultScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final record = app.history.firstOrNull;
    if (record == null) {
      return PageFrame(
        title: 'Your Activity',
        child: Center(
          child: PrimaryButton(
            'Start an Activity',
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/activity'),
          ),
        ),
      );
    }
    final miles = !app.metric;
    final distance = record.distance * (miles ? .621371 : 1);
    final speed = record.seconds == 0
        ? 0.0
        : distance / (record.seconds / 3600);
    final date =
        '${record.date.year} ${record.date.month.toString().padLeft(2, '0')} ${record.date.day.toString().padLeft(2, '0')}';
    return PageFrame(
      back: false,
      child: ListView(
        padding: const EdgeInsets.only(top: 34, bottom: 20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: const SizedBox(height: 260, child: MapCanvas(route: true)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(
                record.kind == ActivityKind.cycling
                    ? Icons.pedal_bike
                    : Icons.directions_run,
                size: 25,
              ),
              const SizedBox(width: 12),
              Text(
                '${record.kind.label} · $date',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 30),
          for (final row in [
            [
              ('Distance', distance.toStringAsFixed(2), miles ? 'mi' : 'km'),
              ('Duration', clockText(record.seconds, hours: true), ''),
            ],
            [
              (
                'Max Speed',
                (speed * 1.3).toStringAsFixed(1),
                miles ? 'mi/h' : 'km/h',
              ),
              ('Avg Speed', speed.toStringAsFixed(1), miles ? 'mi/h' : 'km/h'),
            ],
            [
              ('Max Elevation', '58', 'm'),
              ('Calories Burn', '${record.calories}', 'Kcal'),
            ],
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                children: row
                    .map(
                      (value) => Expanded(
                        child: Column(
                          children: [
                            Text(
                              value.$1,
                              style: const TextStyle(
                                color: Palette.muted,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: value.$2,
                                    style: const TextStyle(
                                      fontSize: 25,
                                      height: 1.1,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' ${value.$3}',
                                    style: const TextStyle(
                                      color: Palette.muted,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          const Center(
            child: Text(
              'Speed, distance & elevation are simulated.',
              style: TextStyle(color: Palette.muted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            'Copy Activity Summary',
            icon: Icons.ios_share,
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(
                  text:
                      'Befit · ${record.kind.label}\n$distance ${miles ? 'mi' : 'km'} · ${clockText(record.seconds)} · ${record.calories} kcal\nDemo session',
                ),
              );
              if (context.mounted) {
                toast(
                  context,
                  'Activity summary copied. Paste it wherever you like.',
                );
              }
            },
          ),
          const SizedBox(height: 18),
          TextButton(
            onPressed: () =>
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
            child: const Text(
              'Go to Home',
              style: TextStyle(
                color: Palette.muted,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

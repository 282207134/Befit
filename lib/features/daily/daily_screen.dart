import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_controller.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});
  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  int period = 0;
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final extraMinutes = app.history.fold<int>(
      0,
      (total, item) => total + item.seconds ~/ 60,
    );
    final calories = app.history.fold<int>(
      0,
      (total, item) => total + item.calories,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Row(
          children: [
            const Expanded(child: GradientText('Daily')),
            Segment(
              labels: const ['Today', 'All Days'],
              index: period,
              onChanged: (i) => setState(() => period = i),
            ),
          ],
        ),
        const SizedBox(height: 32),
        _ChartPanel(
          title: period == 0 ? 'Weekly Effort' : 'Monthly Effort',
          number: '${(period == 0 ? 45 : 185) + extraMinutes}',
          unit: 'min',
          bars: false,
          period: period,
        ),
        const SizedBox(height: 16),
        _ChartPanel(
          title: period == 0 ? 'Weekly Calories' : 'Monthly Calories',
          number: '${(period == 0 ? 590 : 2450) + calories}',
          unit: 'Kcal',
          bars: true,
          period: period,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _MiniPanel(
                title: 'Water',
                value: '${app.water}',
                target: '/ 8',
                unit: 'CUPS',
                graphic: SizedBox(
                  width: 60,
                  height: 60,
                  child: CustomPaint(painter: _WaterPainter(app.water / 8)),
                ),
                button: app.water >= 8 ? 'Goal Reached' : 'Drink',
                action: () {
                  app.drink();
                  if (app.water >= 8) {
                    toast(context, 'Daily water goal reached. Well done!');
                  }
                },
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: _MiniPanel(
                title: 'Weight',
                value: (app.weight * (app.metric ? 1 : 2.20462))
                    .toStringAsFixed(1),
                target: app.metric ? '/ 76' : '/ 168',
                unit: app.metric ? 'KG' : 'LB',
                graphic: SizedBox(
                  width: 60,
                  height: 60,
                  child: CustomPaint(
                    painter: const RingPainter(
                      progress: .72,
                      color: Palette.pink,
                      stroke: 5,
                    ),
                    child: const Center(
                      child: Art('challenges/weighticon.png', width: 30),
                    ),
                  ),
                ),
                button: 'Change',
                action: () => editWeight(context),
              ),
            ),
          ],
        ),
        if (period == 1) ...[
          const SizedBox(height: 25),
          const SectionTitle('Activity History'),
          const SizedBox(height: 12),
          if (app.history.isEmpty)
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Your saved sessions will appear here.',
                style: TextStyle(color: Palette.muted),
              ),
            ),
          for (final activity in app.history)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.route_outlined, color: Palette.blue),
              title: Text(
                '${activity.kind.label} · ${activity.distance.toStringAsFixed(2)} km',
              ),
              subtitle: Text(activity.date.toIso8601String().substring(0, 10)),
              trailing: Text(
                '${activity.seconds ~/ 60} min',
                style: const TextStyle(color: Palette.muted),
              ),
            ),
        ],
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'Charts include the design’s sample baseline.',
            style: TextStyle(fontSize: 11, color: Palette.muted),
          ),
        ),
      ],
    );
  }
}

Future<void> editWeight(BuildContext context) async {
  final app = AppScope.of(context);
  final input = TextEditingController(
    text: (app.weight * (app.metric ? 1 : 2.20462)).toStringAsFixed(1),
  );
  final key = GlobalKey<FormState>();
  final result = await showDialog<double>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF292640),
      title: Text('Your Weight (${app.metric ? 'kg' : 'lb'})'),
      content: Form(
        key: key,
        child: TextFormField(
          controller: input,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          validator: (text) {
            final value = double.tryParse(text ?? '');
            final kg = value == null
                ? null
                : value / (app.metric ? 1 : 2.20462);
            return kg == null || kg < 30 || kg > 200
                ? 'Enter ${app.metric ? '30–200 kg' : '66–440 lb'}'
                : null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (key.currentState!.validate()) {
              Navigator.pop(
                context,
                double.parse(input.text) / (app.metric ? 1 : 2.20462),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
  // Let the dialog finish its reverse transition before releasing the controller.
  await Future<void>.delayed(const Duration(milliseconds: 250));
  input.dispose();
  if (result != null) await app.setWeight(result);
}

class _ChartPanel extends StatelessWidget {
  const _ChartPanel({
    required this.title,
    required this.number,
    required this.unit,
    required this.bars,
    required this.period,
  });
  final String title, number, unit;
  final bool bars;
  final int period;
  @override
  Widget build(BuildContext context) => GlassPanel(
    padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
    gradient: const LinearGradient(colors: [Palette.panel, Palette.panel]),
    child: SizedBox(
      height: 148,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                number,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                ' $unit',
                style: const TextStyle(color: Palette.muted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Expanded(
            child: CustomPaint(
              painter: TrendPainter(bars: bars, period: period),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                (period == 0
                        ? ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                        : ['1', '5', '10', '15', '20', '25', '30'])
                    .map(
                      (label) => Text(
                        label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    ),
  );
}

class TrendPainter extends CustomPainter {
  const TrendPainter({this.bars = false, this.period = 0});
  final bool bars;
  final int period;
  @override
  void paint(Canvas canvas, Size size) {
    final guide = Paint()
      ..color = Palette.muted.withValues(alpha: .4)
      ..strokeWidth = 1;
    for (double x = 31; x < size.width; x += 7) {
      canvas.drawCircle(Offset(x, size.height * .55), .5, guide);
    }
    final label = TextPainter(
      text: const TextSpan(
        text: 'Avg.',
        style: TextStyle(
          color: Palette.muted,
          fontSize: 9,
          fontFamily: 'Gilroy',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(canvas, Offset(3, size.height * .55 - 5));
    final values = period == 0
        ? [.17, .16, .72, .42, .96, .12, 1.0]
        : [.32, .65, .49, .84, .57, .92, .77];
    final paint = Paint()..style = PaintingStyle.fill;
    if (bars) {
      for (int i = 0; i < 7; i++) {
        final x = size.width * (i + .5) / 7;
        canvas.drawRect(
          Rect.fromLTWH(x - 5, 2, 10, size.height - 2),
          paint..color = Palette.muted.withValues(alpha: .13),
        );
        final rect = Rect.fromLTWH(
          x - 5,
          size.height * (1 - values[i]),
          10,
          size.height * values[i],
        );
        canvas.drawRect(
          rect,
          paint
            ..color = Colors.white
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF85A9F8), Palette.purple],
            ).createShader(rect),
        );
        paint.shader = null;
      }
    } else {
      final path = Path();
      final points = List.generate(
        7,
        (i) => Offset(
          size.width * (i + .5) / 7,
          size.height * (1 - values[i] * .9),
        ),
      );
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        final mid = (points[i - 1].dx + points[i].dx) / 2;
        path.cubicTo(
          mid,
          points[i - 1].dy,
          mid,
          points[i].dy,
          points[i].dx,
          points[i].dy,
        );
      }
      paint.shader = const LinearGradient(
        colors: [Palette.purple, Palette.blue, Palette.green],
      ).createShader(Offset.zero & size);
      for (final metric in path.computeMetrics()) {
        for (double d = 0; d < metric.length; d += 5) {
          final point = metric.getTangentForOffset(d)!.position;
          canvas.drawCircle(point, 1.1, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(TrendPainter old) =>
      bars != old.bars || period != old.period;
}

class _MiniPanel extends StatelessWidget {
  const _MiniPanel({
    required this.title,
    required this.value,
    required this.target,
    required this.unit,
    required this.graphic,
    required this.button,
    required this.action,
  });
  final String title, value, target, unit, button;
  final Widget graphic;
  final VoidCallback action;
  @override
  Widget build(BuildContext context) => GlassPanel(
    padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Palette.background, Color(0xFF282351)],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            FittedBox(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(target, style: const TextStyle(fontSize: 11)),
                Text(
                  unit,
                  style: const TextStyle(fontSize: 9, color: Palette.muted),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 13),
        graphic,
        const SizedBox(height: 12),
        PrimaryButton(button, compact: true, onPressed: action),
      ],
    ),
  );
}

class _WaterPainter extends CustomPainter {
  const _WaterPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(2);
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Palette.muted.withValues(alpha: .6),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    final y = size.height * (1 - progress.clamp(.1, 1));
    final path = Path()..moveTo(0, y);
    for (double x = 0; x <= size.width; x += 1) {
      path.lineTo(x, y + math.sin(x / 10) * 4);
    }
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9C9AFF), Palette.purple],
        ).createShader(Offset.zero & size),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WaterPainter old) => progress != old.progress;
}

import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final pages = PageController();
  int index = 0;
  final slides = const [
    (
      'healthy',
      'Healthy',
      'A little movement, a little more energy.\nBuild healthy habits that stay with you.',
    ),
    (
      'ontime',
      'On Time',
      'Make room for yourself.\nA few minutes today can change tomorrow.',
    ),
    (
      'strong',
      'Strong',
      'Find your strength, one session at a time.\nSmall steps. Lasting progress.',
    ),
    (
      'competitive',
      'Competitive',
      'Move together. Grow together.\nYour community is here to keep you going.',
    ),
    (
      'befit',
      'Fit!',
      'Your goals. Your pace. Your journey.\nLet’s have some activity!',
    ),
  ];
  void register() {
    if (AppScope.of(context).onboarded) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, '/register');
    }
  }

  @override
  void dispose() {
    pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    back: false,
    padding: 0,
    child: LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: SizedBox(
          height: constraints.maxHeight < 650 ? 650 : constraints.maxHeight,
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: pages,
                  itemCount: 5,
                  onPageChanged: (value) => setState(() => index = value),
                  itemBuilder: (context, i) => Column(
                    children: [
                      const Spacer(),
                      SizedBox(
                        width: 245,
                        height: 245,
                        child: OverflowBox(
                          maxWidth: 400,
                          maxHeight: 602,
                          alignment: const Alignment(0, -.45),
                          child: Art(
                            'slider/${slides[i].$1}.png',
                            width: 400,
                            height: 602,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Be ',
                              style: TextStyle(fontWeight: FontWeight.w300),
                            ),
                            TextSpan(
                              text: slides[i].$2,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        style: const TextStyle(
                          fontSize: 32,
                          color: Color(0xFFB8A3C1),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          slides[i].$3,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.6,
                            color: Palette.muted,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 64,
                height: 64,
                child: PrimaryButton(
                  '',
                  icon: Icons.chevron_right_rounded,
                  onPressed: () {
                    if (index < 4) {
                      pages.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    } else {
                      register();
                    }
                  },
                ),
              ),
              const SizedBox(height: 26),
              TextButton(
                onPressed: register,
                child: Text(
                  index == 4 ? 'Get Started' : 'Skip',
                  style: const TextStyle(
                    color: Palette.muted,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => GestureDetector(
                    onTap: () => pages.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: index == i ? 16 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: index == i ? Palette.purple : Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 55),
            ],
          ),
        ),
      ),
    ),
  );
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  int step = 0;
  final name = TextEditingController();
  final form = GlobalKey<FormState>();
  DateTime birthday = DateTime(1996, 3, 7);
  double height = 180, weight = 75;
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> next() async {
    if (step == 0 && !form.currentState!.validate()) return;
    if (step < 3) {
      setState(() => step++);
      return;
    }
    setState(() => saving = true);
    final app = AppScope.of(context);
    await app.updateProfile(
      name: name.text,
      birthday: birthday,
      height: height,
      weight: weight,
    );
    await app.finishOnboarding();
    if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: step == 0,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) setState(() => step--);
    },
    child: PageFrame(
      back: false,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      if (step > 0)
                        IconButton(
                          tooltip: 'Previous step',
                          onPressed: () => setState(() => step--),
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                      const Spacer(),
                      Text(
                        '${step + 1} / 4',
                        style: const TextStyle(color: Palette.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  GradientText(
                    [
                      'Welcome',
                      'Your Birthday',
                      'Your Height',
                      'Your Weight',
                    ][step],
                    size: 40,
                  ),
                  const Spacer(),
                  if (step == 0)
                    Form(
                      key: form,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thanks for choosing us…',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Let’s Register you in Befit!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 40),
                            TextFormField(
                              key: const ValueKey('register-name'),
                              controller: name,
                              maxLength: 40,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                hintText: 'What’s Your Name?',
                                counterText: '',
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Please enter your name'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (step == 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.cake_outlined,
                            size: 88,
                            color: Palette.muted,
                          ),
                          const SizedBox(height: 35),
                          GlassPanel(
                            onTap: () async {
                              final result = await showDatePicker(
                                context: context,
                                initialDate: birthday,
                                firstDate: DateTime(1920),
                                lastDate: DateTime.now(),
                              );
                              if (result != null) {
                                setState(() => birthday = result);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    birthday.toIso8601String().substring(0, 10),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.calendar_month_outlined),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (step >= 2)
                    Column(
                      children: [
                        SizedBox(
                          width: 210,
                          height: 210,
                          child: CustomPaint(
                            painter: const RingPainter(
                              progress: .62,
                              color: Color(0xFF484271),
                              stroke: 6,
                            ),
                            child: Center(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: (step == 2 ? height : weight)
                                          .toStringAsFixed(0),
                                      style: const TextStyle(
                                        fontSize: 52,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text: step == 2 ? 'cm' : 'kg',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 35),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              step == 2 ? '100 cm' : '30 kg',
                              style: const TextStyle(color: Palette.muted),
                            ),
                            const Expanded(
                              child: Text(
                                'Drag to adjust',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Palette.muted),
                              ),
                            ),
                            Text(
                              step == 2 ? '230 cm' : '200 kg',
                              style: const TextStyle(color: Palette.muted),
                            ),
                          ],
                        ),
                        Slider(
                          key: ValueKey(
                            step == 2 ? 'height-slider' : 'weight-slider',
                          ),
                          value: step == 2 ? height : weight,
                          min: step == 2 ? 100 : 30,
                          max: step == 2 ? 230 : 200,
                          divisions: step == 2 ? 130 : 170,
                          onChanged: (value) => setState(() {
                            if (step == 2) {
                              height = value;
                            } else {
                              weight = value;
                            }
                          }),
                        ),
                      ],
                    ),
                  const Spacer(),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        saving
                            ? 'Saving…'
                            : step == 3
                            ? 'Let’s Go'
                            : 'Next',
                        onPressed: saving ? null : next,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (step > 1)
                    TextButton(
                      onPressed: saving ? null : next,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Palette.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

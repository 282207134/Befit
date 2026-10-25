import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../daily/daily_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.other = false});
  final bool other;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool following = false;
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final total = app.history.fold<double>(45, (sum, r) => sum + r.distance);
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              SizedBox(
                height: 230,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned.fill(
                      child: Art(
                        widget.other
                            ? 'profile/cover.png'
                            : 'profile/my_cover.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Palette.background],
                          ),
                        ),
                      ),
                    ),
                    const Positioned(left: 16, top: 10, child: BackCircle()),
                    Positioned(
                      bottom: 15,
                      child: Avatar(
                        image: widget.other
                            ? 'avatars/avatar.png'
                            : 'profile/my_avatar.png',
                        size: 116,
                        ring: true,
                      ),
                    ),
                    if (!widget.other)
                      Positioned(
                        bottom: 0,
                        child: IconCircle(
                          icon: Icons.edit_outlined,
                          label: 'Edit Profile',
                          size: 33,
                          onTap: () =>
                              Navigator.pushNamed(context, '/edit-profile'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Center(
                child: GradientText(
                  widget.other ? 'Tatiana Kenter' : app.name,
                  size: 32,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8D6E89), Color(0xFF66658B)],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _ProfileStat(
                      'Followers',
                      widget.other ? '3.2' : '2.7',
                      'K',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 44,
                    color: Palette.panel.withValues(alpha: .5),
                  ),
                  Expanded(
                    child: _ProfileStat(
                      'Activity',
                      total.toStringAsFixed(0),
                      'KM',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              Center(
                child: SizedBox(
                  width: 160,
                  child: PrimaryButton(
                    widget.other
                        ? (following ? 'Following' : 'Follow')
                        : 'Edit Profile',
                    compact: true,
                    onPressed: () {
                      if (widget.other) {
                        setState(() => following = !following);
                        toast(
                          context,
                          'Follow status updated for this preview.',
                        );
                      } else {
                        Navigator.pushNamed(context, '/edit-profile');
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          GlassPanel(
                            child: SizedBox(
                              height: 130,
                              child: Center(
                                child: SizedBox(
                                  width: 140,
                                  height: 140,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      for (int i = 0; i < 3; i++)
                                        SizedBox(
                                          width: 140 - i * 32,
                                          height: 140 - i * 32,
                                          child: CustomPaint(
                                            painter: RingPainter(
                                              progress: [.73, .81, .4][i],
                                              color: [
                                                Palette.blue,
                                                Palette.pink,
                                                Palette.yellow,
                                              ][i],
                                              stroke: 13,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _AchievementPanel(image: 'profile/trophy.png'),
                          const SizedBox(height: 10),
                          const GlassPanel(
                            child: SizedBox(
                              height: 56,
                              child: _ProfileStat('Walking', '45', 'KM'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const GlassPanel(
                            child: SizedBox(
                              height: 56,
                              child: _ProfileStat('Running', '17', 'KM'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _AchievementPanel(image: 'profile/medal.png'),
                          const SizedBox(height: 10),
                          GlassPanel(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                const Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Running',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '45',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      'KM',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Palette.muted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const SizedBox(
                                  height: 106,
                                  width: double.infinity,
                                  child: CustomPaint(
                                    painter: TrendPainter(period: 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              if (widget.other)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PrimaryButton(
                    'View Stories',
                    onPressed: () => Navigator.pushNamed(context, '/stories'),
                  ),
                ),
              if (!widget.other && app.history.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SectionTitle('Recent Activity'),
                      const SizedBox(height: 10),
                      for (final item in app.history.take(5))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            item.kind == ActivityKind.cycling
                                ? Icons.pedal_bike
                                : Icons.directions_run,
                            color: Palette.muted,
                          ),
                          title: Text(item.kind.label),
                          subtitle: Text(
                            item.date.toIso8601String().substring(0, 10),
                          ),
                          trailing: Text(
                            '${item.distance.toStringAsFixed(2)} km',
                          ),
                        ),
                    ],
                  ),
                ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Community counts & achievements are sample data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Palette.muted, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat(this.label, this.number, this.unit);
  final String label, number, unit;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 14, height: 1.1, color: Palette.muted),
      ),
      const SizedBox(height: 3),
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: number,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
            TextSpan(
              text: unit,
              style: const TextStyle(
                fontSize: 13,
                color: Palette.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        style: const TextStyle(height: 1.1),
      ),
    ],
  );
}

class _AchievementPanel extends StatelessWidget {
  const _AchievementPanel({required this.image});
  final String image;
  @override
  Widget build(BuildContext context) => GlassPanel(
    child: Column(
      children: [
        ClipRect(
          child: SizedBox(
            height: 94,
            width: double.infinity,
            child: OverflowBox(
              maxWidth: 220,
              maxHeight: 220,
              child: Art(image, width: 220, height: 220),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '×3',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        const Text(
          'Achievements',
          style: TextStyle(fontSize: 16, color: Palette.muted),
        ),
      ],
    ),
  );
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final form = GlobalKey<FormState>();
  late TextEditingController name, height, weight;
  late DateTime birthday;
  bool initialized = false, saving = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) return;
    final app = AppScope.of(context);
    name = TextEditingController(text: app.name);
    height = TextEditingController(text: app.height.toStringAsFixed(0));
    weight = TextEditingController(text: app.weight.toStringAsFixed(1));
    birthday = app.birthday;
    initialized = true;
  }

  @override
  void dispose() {
    name.dispose();
    height.dispose();
    weight.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() => saving = true);
    await AppScope.of(context).updateProfile(
      name: name.text,
      birthday: birthday,
      height: double.parse(height.text),
      weight: double.parse(weight.text),
    );
    if (mounted) {
      Navigator.pop(context);
      toast(context, 'Profile saved.');
    }
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Edit Profile',
    child: Form(
      key: form,
      child: ListView(
        children: [
          const SizedBox(height: 16),
          const Center(
            child: Avatar(image: 'profile/my_avatar.png', size: 96, ring: true),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: name,
            textCapitalization: TextCapitalization.words,
            maxLength: 40,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Please enter your name'
                : null,
          ),
          const SizedBox(height: 14),
          GlassPanel(
            onTap: () async {
              final result = await showDatePicker(
                context: context,
                initialDate: birthday,
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
              );
              if (result != null) setState(() => birthday = result);
            },
            child: Row(
              children: [
                const Icon(Icons.cake_outlined, color: Palette.muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Birthday · ${birthday.toIso8601String().substring(0, 10)}',
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: height,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Height (cm)'),
                  validator: (value) => validateNumber(value, 100, 230),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: weight,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  validator: (value) => validateNumber(value, 30, 200),
                ),
              ),
            ],
          ),
          const SizedBox(height: 36),
          PrimaryButton(
            saving ? 'Saving…' : 'Save Changes',
            onPressed: saving ? null : save,
          ),
        ],
      ),
    ),
  );
}

String? validateNumber(String? value, double min, double max) {
  final number = double.tryParse(value ?? '');
  return number == null || !number.isFinite || number < min || number > max
      ? 'Enter ${min.toInt()}–${max.toInt()}'
      : null;
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return PageFrame(
      title: 'Settings',
      child: ListView(
        children: [
          const SizedBox(height: 24),
          const SectionTitle('Your Preferences'),
          const SizedBox(height: 18),
          GlassPanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Event reminders'),
                  subtitle: const Text('Show saved events in your local inbox'),
                  value: app.reminders,
                  onChanged: app.setReminders,
                ),
                SwitchListTile(
                  title: const Text('Metric units'),
                  subtitle: Text(
                    app.metric ? 'Kilometers & kilograms' : 'Miles & pounds',
                  ),
                  value: app.metric,
                  onChanged: app.setMetric,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const SectionTitle('Befit'),
          const SizedBox(height: 18),
          GlassPanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Edit Profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                ),
                ListTile(
                  leading: const Icon(Icons.auto_awesome_outlined),
                  title: const Text('Replay Introduction'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/onboarding'),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About Befit'),
                  trailing: const Text('1.0.0'),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Befit',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Art(
                      'applogo.png',
                      width: 48,
                      height: 48,
                    ),
                    children: const [
                      Text(
                        'A local Flutter fitness demo built from the Befit Dark Pixso reference. Map, community and chart baseline data are simulated. No health, GPS or cloud service is connected.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Your profile and progress stay on this device.\nHealth services, wearable sync and push delivery are not connected.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Palette.muted, height: 1.7),
          ),
        ],
      ),
    );
  }
}

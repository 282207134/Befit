import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import '../club/club_screen.dart';
import '../challenges/challenges_screen.dart';
import '../daily/daily_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  @override
  Widget build(BuildContext context) => PageFrame(
    back: false,
    padding: 0,
    contours: index == 0,
    bottom: _Navigation(
      index: index,
      onChanged: (value) => setState(() => index = value),
    ),
    child: Column(
      children: [
        const PersistenceBanner(),
        Expanded(
          child: IndexedStack(
            index: index,
            children: const [
              HomeScreen(),
              ClubScreen(),
              ChallengesScreen(),
              DailyScreen(),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Navigation extends StatelessWidget {
  const _Navigation({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    height: 65,
    decoration: const BoxDecoration(
      color: Color(0xFF1A1735),
      border: Border(top: BorderSide(color: Color(0xFF4B4C70), width: .5)),
    ),
    child: Row(
      children: List.generate(
        4,
        (i) => Expanded(
          child: Semantics(
            selected: i == index,
            button: true,
            label: ['Home', 'Club', 'Challenges', 'Daily'][i],
            child: InkWell(
              key: ValueKey('tab-$i'),
              onTap: () => onChanged(i),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Art(
                    'icons/nav${i + 1}.png',
                    width: 27,
                    height: 27,
                    color: i == index ? Colors.white : const Color(0xFFC2C2E3),
                  ),
                  if (i == index)
                    const Positioned(
                      top: -4,
                      child: SizedBox(
                        width: 9,
                        height: 9,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFDDDDEB),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int category = 0;
  final pageController = PageController(viewportFraction: .88);
  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 22),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: 'Menu',
                onPressed: () => Navigator.pushNamed(context, '/menu'),
                icon: const Art('menu.png', width: 27, height: 24),
              ),
              const Art('logo.png', width: 70, height: 30),
              IconButton(
                tooltip: 'My Profile',
                onPressed: () => Navigator.pushNamed(context, '/profile'),
                icon: const Icon(Icons.account_circle_outlined, size: 31),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Let’s Have',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w300),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 5, 16, 24),
          child: GradientText(
            'Some Activity!',
            size: 40,
            gradient: LinearGradient(
              colors: [Palette.pink, Color(0xFF4173CC), Palette.pink],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (final kind in ActivityKind.values) ...[
                if (kind.index > 0) const SizedBox(width: 8),
                Expanded(
                  child: _ActivityCard(
                    kind: kind,
                    distance: app.history
                        .where((r) => r.kind == kind)
                        .fold<double>(0, (sum, r) => sum + r.distance),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              for (int i = 0; i < 4; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 19),
                  child: InkWell(
                    onTap: () {
                      setState(() => category = i);
                      pageController.jumpToPage(0);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ['Strength', 'Cardio', 'Yoga', 'Meditation'][i],
                          style: TextStyle(
                            fontSize: 14,
                            color: i == category ? Colors.white : Palette.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: 11,
                          height: 2,
                          color: i == category
                              ? Colors.white
                              : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 236,
          child: PageView.builder(
            controller: pageController,
            padEnds: false,
            itemCount: 2,
            itemBuilder: (context, i) {
              final id = 'workout-$category-$i';
              return Padding(
                padding: EdgeInsets.only(left: i == 0 ? 16 : 8, right: 8),
                child: _WorkoutCard(
                  category: category,
                  index: i,
                  favorite: app.favorites.contains(id),
                  onFavorite: () => app.toggleFavorite(id),
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/workout',
                    arguments: category == 2
                        ? 'yoga'
                        : category == 3
                        ? 'meditation'
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.kind, required this.distance});
  final ActivityKind kind;
  final double distance;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Start ${kind.label}',
    child: GlassPanel(
      padding: EdgeInsets.zero,
      radius: 18,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF747697), Color(0xFF3C3D67)],
      ),
      onTap: () => Navigator.pushNamed(context, '/activity', arguments: kind),
      child: SizedBox(
        height: 162,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: .18,
                child: Art(
                  '${['walking', 'running', 'cycling'][kind.index]}_bg.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(9, 18, 9, 10),
              child: Column(
                children: [
                  Art('icons/${kind.asset}.png', width: 55, height: 43),
                  const Spacer(),
                  FittedBox(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          kind == ActivityKind.walking
                              ? '2314'
                              : (distance +
                                        (kind == ActivityKind.running
                                            ? 3.7
                                            : 0))
                                    .toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          kind == ActivityKind.walking
                              ? ' / 8000\nSTEPS'
                              : ' KM',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFD7D7EE),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD8D9EB), Colors.white],
                      ),
                    ),
                    child: Text(
                      kind.label,
                      style: const TextStyle(
                        color: Palette.panel,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.category,
    required this.index,
    required this.favorite,
    required this.onFavorite,
    required this.onTap,
  });
  final int category, index;
  final bool favorite;
  final VoidCallback onFavorite, onTap;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Art(index == 0 ? 'card1.png' : 'card2.png', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: category == 0 && index == 0
                    ? [
                        const Color(0xFFEF7274).withValues(alpha: .2),
                        const Color(0xFFA44B9C).withValues(alpha: .75),
                      ]
                    : [
                        Palette.purple.withValues(alpha: .2),
                        Palette.purple.withValues(alpha: .8),
                      ],
              ),
            ),
          ),
          const Art('cardcover.png', fit: BoxFit.cover),
          Positioned(
            left: 30,
            bottom: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [
                    'Make\nYour Back',
                    'Find Your\nOwn Pace',
                    'Breathe.\nFind Balance.',
                    'A Moment\nFor Yourself',
                  ][category],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    height: 1.12,
                  ),
                ),
                Text(
                  ['Massive', 'Stronger', 'Flow', 'Be Present'][category],
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: IconButton(
              tooltip: favorite ? 'Remove favorite' : 'Add favorite',
              onPressed: onFavorite,
              icon: Icon(
                favorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return PageFrame(
      contours: true,
      child: ListView(
        children: [
          const SizedBox(height: 8),
          const Center(
            child: Avatar(image: 'profile/my_avatar.png', size: 100),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Hello',
              style: TextStyle(color: Palette.muted, fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              app.name.split(' ').first,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 35),
          for (final item in [
            (Icons.account_circle_outlined, 'My Profile', '/profile'),
            (Icons.favorite_border, 'My Favorite', '/favorites'),
            (Icons.tune_rounded, 'General Setting', '/settings'),
          ])
            ListTile(
              leading: Icon(item.$1),
              title: Text(
                item.$2,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: const Icon(Icons.chevron_right, color: Palette.muted),
              onTap: () => Navigator.pushNamed(context, item.$3),
            ),
          ListTile(
            leading: const Art('sidemenu/applehealth.png', width: 32),
            title: const Text('Apple Health'),
            trailing: const Text(
              'Preview',
              style: TextStyle(color: Palette.muted),
            ),
            onTap: () => toast(
              context,
              'Health integration is not connected in this local demo.',
            ),
          ),
          ListTile(
            leading: const Art('sidemenu/smartwatch.png', width: 32),
            title: const Text('Smart Watch'),
            trailing: const Text(
              'Preview',
              style: TextStyle(color: Palette.muted),
            ),
            onTap: () => toast(
              context,
              'No wearable connected. Activity tracking uses demo data.',
            ),
          ),
          const SizedBox(height: 25),
          GlassPanel(
            onTap: () => Navigator.pop(context),
            child: const Row(
              children: [
                Art('logo.png', width: 70),
                Spacer(),
                Text('Let’s have some activity!'),
                Icon(Icons.arrow_forward_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return PageFrame(
      title: 'My Favorite',
      child: app.favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 58,
                    color: Palette.muted,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'A little motivation, saved.',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tap the heart on a workout to find it here.',
                    style: TextStyle(color: Palette.muted),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    'Explore Workouts',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            )
          : ListView(
              children: app.favorites.map((id) {
                final parts = id.split('-');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SizedBox(
                    height: 236,
                    child: _WorkoutCard(
                      category: int.parse(parts[1]),
                      index: int.parse(parts[2]),
                      favorite: true,
                      onFavorite: () => app.toggleFavorite(id),
                      onTap: () => Navigator.pushNamed(context, '/workout'),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

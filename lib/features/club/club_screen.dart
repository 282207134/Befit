import 'package:flutter/material.dart';

import '../../core/app_controller.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';
import 'map_screen.dart';

class ClubScreen extends StatelessWidget {
  const ClubScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Row(
          children: [
            const Expanded(child: GradientText('My Club')),
            IconButton(
              tooltip: 'Notifications',
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
              icon: const Badge(
                smallSize: 7,
                child: Icon(
                  Icons.notifications_rounded,
                  color: Palette.muted,
                  size: 27,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Club messages',
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                backgroundColor: Palette.background,
                builder: (_) => const Padding(
                  padding: EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.forum_outlined,
                        color: Palette.muted,
                        size: 40,
                      ),
                      SizedBox(height: 18),
                      Text(
                        'You’re all caught up',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Club messages will appear here when a messaging service is connected.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Palette.muted),
                      ),
                      SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
              icon: const Badge(
                smallSize: 7,
                child: Icon(
                  Icons.chat_bubble_rounded,
                  color: Palette.muted,
                  size: 25,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            separatorBuilder: (_, _) => const SizedBox(width: 13),
            itemBuilder: (context, i) => i == 0
                ? Align(
                    alignment: Alignment.topCenter,
                    child: IconCircle(
                      icon: Icons.add,
                      label: 'Your story',
                      size: 54,
                      onTap: () => toast(
                        context,
                        'Story uploads are not connected in this local demo.',
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Avatar(
                        image: 'avatars/avatar${i == 1 ? '' : i - 1}.png',
                        size: 54,
                        ring: true,
                        onTap: () => Navigator.pushNamed(context, '/stories'),
                      ),
                      if (i == 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Palette.pink,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 22),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 260,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/map'),
                    child: const MapCanvas(),
                  ),
                ),
                Positioned(
                  left: 5,
                  right: 5,
                  bottom: 8,
                  child: FriendStrip(
                    onTap: () => Navigator.pushNamed(context, '/map'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        const SectionTitle('Club Events'),
        const SizedBox(height: 22),
        for (int i = 0; i < 2; i++)
          Padding(
            padding: const EdgeInsets.only(left: 26, bottom: 16),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GlassPanel(
                  padding: const EdgeInsets.fromLTRB(57, 13, 10, 13),
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    backgroundColor: Palette.background,
                    builder: (_) => Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Art(
                            'icons/${i == 0 ? 'bike-bicycle' : 'running'}.png',
                            width: 60,
                            height: 60,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            i == 0
                                ? 'Sunday Cycling Club'
                                : 'Evening Running Club',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'A friendly group session for every level. This event is a local preview.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Palette.muted),
                          ),
                          const SizedBox(height: 24),
                          PrimaryButton(
                            'Start ${i == 0 ? 'Cycling' : 'Running'}',
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                context,
                                '/activity',
                                arguments: i == 0
                                    ? ActivityKind.cycling
                                    : ActivityKind.running,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 48,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            i == 0 ? '#24' : '#09',
                            style: const TextStyle(
                              fontSize: 28,
                              color: Palette.panel,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          i == 0 ? 'Cycling Event' : 'Running Event',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        i == 0 ? '5 Mar\n15:00' : '8 Mar\n20:30',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Palette.muted,
                          height: 1.5,
                        ),
                      ),
                      IconButton(
                        tooltip: app.eventReminders.contains(i)
                            ? 'Remove event reminder'
                            : 'Save event reminder',
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          app.toggleEvent(i);
                          toast(
                            context,
                            app.eventReminders.contains(i)
                                ? 'Event saved to your local reminders.'
                                : 'Event reminder removed.',
                          );
                        },
                        icon: Icon(
                          app.eventReminders.contains(i)
                              ? Icons.notifications_active
                              : Icons.notifications_none,
                          color: Palette.yellow,
                          size: 21,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: -5,
                  top: 8,
                  child: Container(
                    width: 50,
                    height: 52,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(17),
                      gradient: LinearGradient(
                        colors: i == 0
                            ? [const Color(0xFFFFEEC5), Palette.yellow]
                            : [const Color(0xFFFF7CA7), Palette.pink],
                      ),
                    ),
                    child: Art(
                      'icons/${i == 0 ? 'bike-bicycle' : 'running'}.png',
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return PageFrame(
      title: 'Notifications',
      child: ListView(
        children: [
          const SizedBox(height: 16),
          GlassPanel(
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.waving_hand_outlined, color: Palette.yellow),
              title: Text('Welcome to your club!'),
              subtitle: Text('Your next activity starts with one small step.'),
            ),
          ),
          const SizedBox(height: 16),
          if (!app.reminders)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Event reminders are turned off in Settings.',
                style: TextStyle(color: Palette.muted),
              ),
            ),
          if (app.eventReminders.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Save a club event to see your local reminders here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Palette.muted),
              ),
            ),
          for (final id in app.reminders ? app.eventReminders : <int>{})
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassPanel(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.notifications_active_outlined,
                    color: Palette.pink,
                  ),
                  title: Text(id == 0 ? 'Cycling Event' : 'Running Event'),
                  subtitle: const Text(
                    'Saved locally · no scheduled push notification',
                  ),
                  trailing: IconButton(
                    tooltip: 'Remove reminder',
                    onPressed: () => app.toggleEvent(id),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

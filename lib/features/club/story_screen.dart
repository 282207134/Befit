import 'package:flutter/material.dart';

import '../../core/widgets.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});
  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  int index = 0;
  final liked = <int>{};
  final images = ['story.png', 'story2.jpg', 'story3.jpg', 'story4.jpg'];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTapUp: (details) {
            final forward =
                details.localPosition.dx > MediaQuery.sizeOf(context).width / 2;
            if (forward && index == 3) {
              Navigator.pop(context);
            } else {
              setState(() => index = (index + (forward ? 1 : -1)).clamp(0, 3));
            }
          },
          child: Art('stories/${images[index]}', fit: BoxFit.cover),
        ),
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x55000000),
                  Colors.transparent,
                  Color(0x66000000),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              children: [
                Row(
                  children: List.generate(
                    4,
                    (i) => Expanded(
                      child: Container(
                        height: 3,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          color: i <= index ? Colors.white : Colors.white38,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Avatar(image: 'stories/avatar.png', size: 44),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Eliza Nichols',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text('10 min ago', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.near_me, size: 16),
                    const SizedBox(width: 5),
                    const Text('Liden, Sweden', style: TextStyle(fontSize: 12)),
                    IconButton(
                      tooltip: 'Close story',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
                const Spacer(),
                IconCircle(
                  icon: liked.contains(index)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  label: 'Like story locally',
                  size: 70,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: .23),
                      Colors.white.withValues(alpha: .1),
                    ],
                  ),
                  onTap: () => setState(() {
                    if (!liked.add(index)) liked.remove(index);
                  }),
                ),
                const SizedBox(height: 12),
                Text(
                  '${459 + (liked.contains(index) ? 1 : 0)} Likes',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

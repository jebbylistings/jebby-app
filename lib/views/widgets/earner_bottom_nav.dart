import 'package:flutter/material.dart';
import 'package:jebby/constants/color.dart';

class EarnerBottomNav extends StatelessWidget {
  const EarnerBottomNav({
    super.key,
    required this.activeIndex,
    required this.onTap,
    this.inboxBadge = 0,
  });

  final int activeIndex;
  final ValueChanged<int> onTap;
  final int inboxBadge;

  static const Color _inactive = Color(0xFFB5B5B5);
  static const double _iconSize = 26;
  static const double _labelGap = 4;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 6, 8, bottomPad > 0 ? bottomPad - 2 : 6),
        child: Row(
          children: [
            Expanded(
              child: _navItem(
                index: 0,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
              ),
            ),
            Expanded(
              child: _navItem(
                index: 1,
                icon: Icons.chat_outlined,
                selectedIcon: Icons.chat,
                label: 'Inbox',
                badge: inboxBadge,
              ),
            ),
            Expanded(
              child: _navItem(
                index: 2,
                icon: Icons.person_2_outlined,
                selectedIcon: Icons.person_2,
                label: 'Profile',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    int badge = 0,
  }) {
    final selected = activeIndex == index;
    final color = selected ? AppColors.jebbyBlue : _inactive;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: _iconSize,
                width: _iconSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      selected ? selectedIcon : icon,
                      size: _iconSize,
                      color: color,
                    ),
                    if (badge > 0)
                      Positioned(
                        top: -4,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.jebbyBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            badge > 9 ? '9+' : '$badge',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: _labelGap),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: color,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

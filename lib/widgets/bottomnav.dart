import 'package:flutter/material.dart';

class CommonBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const CommonBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });
  static const _primary = Color(0xFFFFFFFF);
  static const _inactive = Color(0xFFB8BED3);
  static const _bg = Color(0xFF2523A8);
  // static const _primary = Color(0xFFFFFFFF);
  // static const _inactive = Color(0xFFBFC5D6);
  // static const _bg = Color(0xFF2C2AC0);
  static const _items = [
    (icon: Icons.home_outlined, active: Icons.home, label: 'Home'),
    (icon: Icons.history_outlined, active: Icons.history, label: 'History'),
    (
      icon: Icons.file_upload_outlined,
      active: Icons.file_upload,
      label: 'Export',
    ),
    (icon: Icons.person_outline, active: Icons.person, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: SizedBox(
            height: 72,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (index) {
                final item = _items[index];
                return _NavItem(
                  icon: item.icon,
                  activeIcon: item.active,
                  label: item.label,
                  isSelected: selectedIndex == index,
                  primary: _primary,
                  inactive: _inactive,
                  onTap: () => onItemSelected(index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final Color primary;
  final Color inactive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.primary,
    required this.inactive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? primary : inactive;

    return Expanded(
      child: Semantics(
        selected: isSelected,
        button: true,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: primary.withValues(alpha: 0.12),
            highlightColor: primary.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      isSelected ? activeIcon : icon,
                      size: 22,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: color,
                    ),
                    child: Text(label),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

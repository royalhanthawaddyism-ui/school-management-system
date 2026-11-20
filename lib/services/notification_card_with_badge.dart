import 'package:flutter/material.dart';

class NotificationCardWithBadge extends StatelessWidget {
  const NotificationCardWithBadge({
    super.key,
    required this.hasUnread,
    required this.child,
    this.onTap,
    this.badgeColor = Colors.red,
    this.badgeBorderColor = Colors.white,
    this.badgeSize = 20,
    this.topOffset = -6,
    this.rightOffset = -6,
    this.cardMargin = EdgeInsets.zero,
    this.borderRadius = 12,
  });

  final bool hasUnread;
  final Widget child;
  final VoidCallback? onTap;
  final Color badgeColor;
  final Color badgeBorderColor;
  final double badgeSize;
  final double topOffset;
  final double rightOffset;
  final EdgeInsetsGeometry cardMargin;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          margin: cardMargin,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: child,
          ),
        ),
        if (hasUnread)
          Positioned(
            top: topOffset,
            right: rightOffset,
            child: IgnorePointer(
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: badgeBorderColor, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '!',
                  style: TextStyle(
                    color: badgeBorderColor,
                    fontSize: badgeSize * 0.6,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
// lib/core/presentation/widgets/avatar_widget.dart

import 'package:flutter/material.dart';

import '../../utils/avatar_utils.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget({
    super.key,
    required this.name,
    required this.id,
    this.radius = 24,
  });

  final String name;
  final String id;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = AvatarUtils.colorForId(id);
    final initials = AvatarUtils.initialsFromName(name);

    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withAlpha(40),
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontSize: radius * 0.65,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

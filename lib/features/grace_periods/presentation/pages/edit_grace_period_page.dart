// lib/features/grace_periods/presentation/pages/edit_grace_period_page.dart

import 'package:flutter/material.dart';

class EditGracePeriodPage extends StatelessWidget {
  const EditGracePeriodPage({super.key, required this.gracePeriodId});
  final String gracePeriodId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Edit Grace Period: $gracePeriodId')),
    );
  }
}

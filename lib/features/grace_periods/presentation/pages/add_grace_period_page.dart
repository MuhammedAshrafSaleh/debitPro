// lib/features/grace_periods/presentation/pages/add_grace_period_page.dart

import 'package:flutter/material.dart';

class AddGracePeriodPage extends StatelessWidget {
  const AddGracePeriodPage({super.key, required this.clientId});
  final String clientId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Add Grace Period for: $clientId')),
    );
  }
}

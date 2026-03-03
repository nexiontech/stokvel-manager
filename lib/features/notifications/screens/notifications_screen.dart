import 'package:flutter/material.dart';
import '../../../shared/widgets/empty_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: const EmptyState(
        icon: Icons.notifications_none,
        title: 'No Notifications',
        message: 'You\'re all caught up! Notifications will appear here.',
      ),
    );
  }
}

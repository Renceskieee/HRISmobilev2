// ignore_for_file: library_prefixes, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:hris_mobile/services/socket_service.dart';
import 'package:provider/provider.dart';
import 'package:hris_mobile/components/snackbar.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    // Access the SocketService in initState, but don't listen to changes here
    // ignore: unused_local_variable
    final socketService = Provider.of<SocketService>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    final notifications = socketService.notifications;
    final isConnected = socketService.isConnected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Icon(
            isConnected ? Icons.cloud_done : Icons.cloud_off,
            color: isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: notifications.isEmpty
          ? (socketService.isLoadingHistorical
              ? const Center(child: CircularProgressIndicator())
              : const Center(
                  child: Text(
                    'No notifications yet.\nWaiting for leave status updates...',
                    textAlign: TextAlign.center,
                  ),
                ))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final DateTime time = notif['time']; // time is now stored as DateTime in SocketService
                final String leaveStatus = notif['status'] ?? 'N/A';
                final String leaveType = notif['leave_type'] ?? 'N/A';
                final String firstName = notif['f_name'] ?? '';
                final String lastName = notif['l_name'] ?? '';
                final bool isRead = notif['isRead'] ?? true; // Default to true if isRead is missing

                IconData icon;
                Color iconColor;
                String title = 'Leave Request Status Update'; // Default title
                String subtitle;
                String expandedDetails;

                subtitle = 'Leave request for $firstName $lastName ($leaveType) is now $leaveStatus. • ${_formatTime(time)}';

                expandedDetails = 'Leave Type: $leaveType\nStatus: $leaveStatus\nEmployee: $firstName $lastName\nTime: ${_formatTime(time)}';

                switch (leaveStatus.toLowerCase()) {
                  case 'approved':
                    icon = Icons.check_circle_outline;
                    iconColor = Colors.green;
                    break;
                  case 'rejected':
                    icon = Icons.cancel_outlined;
                    iconColor = Colors.red;
                    break;
                  case 'pending':
                    icon = Icons.hourglass_empty;
                    iconColor = Colors.orange;
                    break;
                  default:
                    icon = Icons.info_outline;
                    iconColor = Colors.blue;
                }

                return Card(
                  color: isRead ? Colors.white : Colors.grey[200], // Visual cue for unread
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: iconColor.withOpacity(0.1),
                      child: Icon(icon, color: iconColor),
                    ),
                    title: Text(
                      title,
                      style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                    ),
                    subtitle: Text(
                      subtitle,
                      style: TextStyle(color: iconColor, fontSize: 12),
                    ),
                    onExpansionChanged: (isExpanded) {
                      if (isExpanded && !isRead) {
                        socketService.markNotificationAsRead(notif);
                      }
                      if (!isExpanded) {
                        // Optional: Do something when collapsed
                      }
                    },
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            expandedDetails,
                            style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          socketService.clearNotifications();
          showCustomSnackBar(context, 'Notifications cleared');
        },
        tooltip: 'Clear All',
        child: const Icon(Icons.clear_all),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

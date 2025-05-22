// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SocketService extends ChangeNotifier {
  io.Socket? _socket;
  final List<Map<String, dynamic>> _notifications = [];
  final List<Map<String, dynamic>> _unreadNotifications = [];
  bool _isConnected = false;
  final int userId;
  bool _isLoadingHistorical = false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  List<Map<String, dynamic>> get notifications => _notifications;
  List<Map<String, dynamic>> get unreadNotifications => _unreadNotifications;
  bool get isConnected => _isConnected;
  bool get isLoadingHistorical => _isLoadingHistorical;

  SocketService({required this.userId}) {
    _connectSocket();
    _initializeLocalNotifications();
    _fetchHistoricalNotifications();
  }

  void _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon'); // Use app_icon for standard Android notifications
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _fetchHistoricalNotifications() async {
    _isLoadingHistorical = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('http://192.168.99.139:3000/api/notifications/user/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _notifications.clear(); // Clear any initial empty list
        // Add historical notifications, marking them as read and parsing time
        for (var notifData in data) {
          _notifications.add({
            'id': notifData['id'],
            'user_id': notifData['user_id'],
            'leave_request_id': notifData['leave_request_id'],
            'status': notifData['status'],
            'leave_type': notifData['leave_type'],
            'f_name': notifData['f_name'],
            'l_name': notifData['l_name'],
            'time': DateTime.parse(notifData['time']), // Parse historical time
            'isRead': true, // Historical notifications are initially read
          });
        }
        // Sort historical notifications by time (newest first)
        _notifications.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

      } else {
        if (kDebugMode) {
          print('Failed to fetch historical notifications: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching historical notifications: $e');
      }
    } finally {
      _isLoadingHistorical = false;
      notifyListeners();
    }
  }

  void _connectSocket() {
    try {
      _socket = io.io('http://192.168.99.139:3000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false, // We will connect manually
      });

      _socket?.onConnect((_) {
        _isConnected = true;
        if (kDebugMode) {
          print('Socket connected: ${_socket?.id}');
        }
        notifyListeners();
        // You might want to emit something here to identify the user
        // _socket?.emit('authenticate', {'userId': userId});
      });

      _socket?.onDisconnect((_) {
        _isConnected = false;
        if (kDebugMode) {
          print('Socket disconnected');
        }
        notifyListeners();
      });

      _socket?.onConnectError((data) {
        if (kDebugMode) { print('Connect Error: $data'); }
      });
      _socket?.onError((data) {
        if (kDebugMode) { print('Socket Error: $data'); }
      });
      _socket?.on('error', (data) {
         if (kDebugMode) { print('Socket Error (event): $data'); }
      });

      // Listen for leave status updates
      _socket?.on('leave_status_updated', (data) {
        if (kDebugMode) {
          print('Leave status updated received: $data');
        }
        if (data != null && data['payload'] != null) {
          final payload = data['payload'];

          final notification = {
            'leave_request_id': payload['leave_request_id'],
            'status': payload['status'],
            'employee_id': payload['employee_id'],
            'leave_type': payload['leave_type'],
            'f_name': payload['f_name'],
            'l_name': payload['l_name'],
            'time': DateTime.parse(payload['created_at']), // Use backend created_at
            'isRead': false, // Mark as unread initially
          };
          // Add real-time notification and keep the list sorted by time (newest first)
          // First, remove any existing notification for the same leave request ID
          _notifications.removeWhere((n) => n['leave_request_id'] == notification['leave_request_id']);
          _notifications.insert(0, notification); // Insert at the beginning as it's newest
          // Sorting might not be strictly necessary here if we always insert at 0,
          // but good practice to keep the list consistently sorted.
          _notifications.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

          _unreadNotifications.add(notification); // Add to unread list
          notifyListeners();

           _showLocalNotification(
             'EARIST HRIS',
             'You have a new notification',
             payload: notification // Pass full notification data to local notification
           );
        }
      });

       _socket?.on('db_change', (data) {
         if (kDebugMode) {
           print('DB change received: $data');
         }
          // Handle other database changes if needed, potentially show local notification
       });

      _socket?.connect(); // Connect manually

    } catch (e) {
      if (kDebugMode) {
        print('Error connecting to socket: $e');
      }
      _isConnected = false;
      notifyListeners();
    }
  }

  void clearNotifications() {
    _notifications.clear();
    _unreadNotifications.clear(); // Clear unread list as well
    notifyListeners();
  }

  void markNotificationAsRead(Map<String, dynamic> notification) {
    // Find the notification by a unique identifier (like leave_request_id and time)
    final notificationToMark = _notifications.firstWhere(
      (n) => n['leave_request_id'] == notification['leave_request_id'] && (n['time'] as DateTime).isAtSameMomentAs(notification['time'] as DateTime),
      orElse: () => {}, // Return an empty map if not found
    );

    if (notificationToMark.isNotEmpty && !(notificationToMark['isRead'] ?? true)) {
      notificationToMark['isRead'] = true;
      _unreadNotifications.removeWhere(
        (n) => n['leave_request_id'] == notification['leave_request_id'] && (n['time'] as DateTime).isAtSameMomentAs(notification['time'] as DateTime),
      );
      notifyListeners();
    }
  }

  Future<void> _showLocalNotification(String title, String body, {Map<String, dynamic>? payload}) async {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'notification_channel_id', // Channel ID
        'Notification Channel', // Channel name
        channelDescription: 'Channel for HRIS notifications', // Channel description
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
        // Add icon if you have a specific one for notifications
        // icon: '@drawable/notification_icon', // Example
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        payload?['leave_request_id']?.hashCode ?? 0, // Use unique ID for each notification
        title,
        body,
        platformChannelSpecifics,
        payload: payload != null ? json.encode(payload) : null, // Pass payload as string
      );
  }

  @override
  void dispose() {
    _socket?.off('connect');
    _socket?.off('disconnect');
    _socket?.off('connect_error');
    _socket?.off('error');
    _socket?.off('leave_status_updated');
    _socket?.off('db_change');
    _socket?.off('error'); // Also explicitly turn off the generic error listener
    _socket?.dispose();
    super.dispose();
  }
}

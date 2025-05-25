// ignore_for_file: avoid_print

import 'dart:ui';
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

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _fetchHistoricalNotifications() async {
    _isLoadingHistorical = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://192.168.99.139:3000/api/notifications/user/$userId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _notifications.clear();

        for (var notifData in data) {
          final DateTime datePart = DateTime.parse(notifData['date']).toLocal();
          final List<String> timeParts = notifData['time'].split(':');
          final int hour = int.parse(timeParts[0]);
          final int minute = int.parse(timeParts[1]);
          final int second = int.parse(timeParts[2]);

          final DateTime notificationDateTime = DateTime(
            datePart.year,
            datePart.month,
            datePart.day,
            hour,
            minute,
            second,
          );

          _notifications.add({
            'id': notifData['id'],
            'user_id': notifData['user_id'],
            'leave_request_id': notifData['leave_request_id'],
            'status': notifData['status'],
            'leave_type': notifData['leave_type'],
            'f_name': notifData['f_name'],
            'l_name': notifData['l_name'],
            'time': notificationDateTime,
            'isRead': true,
          });
        }

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
      _socket = io.io('http://192.168.99.139:3000', {
        'transports': ['websocket'],
        'autoConnect': false,
      });

      _socket?.onConnect((_) {
        _isConnected = true;
        print('Socket connected: ${_socket?.id}');
        notifyListeners();
      });

      _socket?.onDisconnect((_) {
        _isConnected = false;
        print('Socket disconnected');
        notifyListeners();
      });

      _socket?.onConnectError((data) {
        print('Connect Error: $data');
      });

      _socket?.onError((data) {
        print('Socket Error: $data');
      });

      _socket?.on('leave_status_updated', (data) {
        if (kDebugMode) {
          print('Leave status update: $data');
        }

        final payload = data['payload'];
        if (payload != null &&
            payload['date'] != null &&
            payload['time'] != null) {
          final DateTime datePart = DateTime.parse(payload['date']).toLocal();
          final List<String> timeParts = payload['time'].split(':');
          final DateTime notificationDateTime = DateTime(
            datePart.year,
            datePart.month,
            datePart.day,
            int.parse(timeParts[0]),
            int.parse(timeParts[1]),
            int.parse(timeParts[2]),
          );

          final notification = {
            'leave_request_id': payload['leave_request_id'],
            'status': payload['status'],
            'employee_id': payload['employee_id'],
            'leave_type': payload['leave_type'],
            'f_name': payload['f_name'],
            'l_name': payload['l_name'],
            'time': notificationDateTime,
            'isRead': false,
          };

          _notifications.removeWhere(
              (n) => n['leave_request_id'] == notification['leave_request_id']);
          _notifications.insert(0, notification);
          _notifications.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

          _unreadNotifications.add(notification);
          notifyListeners();

          _showLocalNotification(
            'EARIST HRIS',
            '${payload['f_name']} ${payload['l_name']} - ${payload['leave_type']} is now ${payload['status']}',
            payload: notification,
          );
        }
      });

      _socket?.connect();
    } catch (e) {
      print('Socket connection error: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  Future<void> refreshNotifications() async {
    await _fetchHistoricalNotifications();
  }

  void markNotificationAsRead(Map<String, dynamic> notification) {
    final notificationToMark = _notifications.firstWhere(
      (n) =>
          n['leave_request_id'] == notification['leave_request_id'] &&
          (n['time'] as DateTime).isAtSameMomentAs(notification['time'] as DateTime),
      orElse: () => {},
    );

    if (notificationToMark.isNotEmpty && !(notificationToMark['isRead'] ?? true)) {
      notificationToMark['isRead'] = true;
      _unreadNotifications.removeWhere(
        (n) =>
            n['leave_request_id'] == notification['leave_request_id'] &&
            (n['time'] as DateTime).isAtSameMomentAs(notification['time'] as DateTime),
      );
      notifyListeners();
    }
  }

  Future<void> _showLocalNotification(String title, String body,
      {Map<String, dynamic>? payload}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'notification_channel_id',
      'HRIS Notification Channel',
      channelDescription: 'This channel is used for HRIS notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      color: Color(0xFF0056b3),
      icon: 'app_icon',
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      payload?['leave_request_id']?.hashCode ?? 0,
      title,
      body,
      platformChannelSpecifics,
      payload: payload != null ? json.encode(payload) : null,
    );
  }

  @override
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }
}

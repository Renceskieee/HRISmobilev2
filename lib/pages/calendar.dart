// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const Color holidayColor = Color(0xFFA31D1D);
const Color selectedDayColor = Color(0xFFE5D0AC);
const Color todayColor = Color(0xFFA31D1D);
const Color cardBackground = Color(0xFFFFF6EF);

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _holidays = {};
  List<dynamic> _selectedEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchHolidays();
  }

  Future<void> _fetchHolidays() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.99.139:3000/api/holidays'));
      if (response.statusCode == 200) {
        final List<dynamic> holidayData = json.decode(response.body);
        final Map<DateTime, List<dynamic>> holidaysMap = {};
        for (var holiday in holidayData) {
          final date = DateTime.parse(holiday['date']).add(const Duration(days: 1));
          final normalizedDate = DateTime(date.year, date.month, date.day);
          holidaysMap.putIfAbsent(normalizedDate, () => []).add(holiday);
        }
        setState(() {
          _holidays = holidaysMap;
        });
      } else {
        print('Failed to fetch holidays: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching holidays: $e');
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _holidays[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final normalizedSelectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
    final normalizedFocusedDay = DateTime(focusedDay.year, focusedDay.month, focusedDay.day);

    if (!isSameDay(_selectedDay, normalizedSelectedDay)) {
      setState(() {
        _selectedDay = normalizedSelectedDay;
        _focusedDay = normalizedFocusedDay;
        _selectedEvents = _getEventsForDay(normalizedSelectedDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'en_US',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              markersMaxCount: 1,
              markerDecoration: BoxDecoration(
                color: holidayColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: todayColor,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
              defaultTextStyle: TextStyle(fontFamily: 'Poppins'),
              weekendTextStyle: TextStyle(fontFamily: 'Poppins'),
              outsideTextStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
              selectedDecoration: BoxDecoration(
                color: selectedDayColor,
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(fontFamily: 'Poppins', color: Colors.black),
            ),
            headerStyle: const HeaderStyle(
              titleTextStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _selectedEvents.isEmpty
                ? const Center(
                    child: Text(
                      'No holidays on this day.',
                      style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _selectedEvents.length,
                    itemBuilder: (context, index) {
                      final holiday = _selectedEvents[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          color: cardBackground,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.event, color: holidayColor),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        holiday['holiday_name'],
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 6,
                                  children: [
                                    _infoChip('Type', holiday['type'], Icons.category),
                                    _infoChip(
                                      'Movable',
                                      holiday['is_movable'] == 1 ? 'Yes' : 'No',
                                      Icons.swap_horiz,
                                    ),
                                  ],
                                ),
                                if (holiday['notes'] != null) ...[
                                  const SizedBox(height: 12),
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text(holiday['holiday_name']),
                                          content: Text(holiday['notes']),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(),
                                              child: const Text(
                                                'Close',
                                                style: TextStyle(color: Color.fromRGBO(163, 29, 29, 1)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: const [
                                        Icon(Icons.info_outline, color: holidayColor),
                                        SizedBox(width: 8),
                                        Text(
                                          'View Notes',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            color: holidayColor,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.white),
      label: Text(
        '$label: $value',
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: Colors.white,
        ),
      ),
      backgroundColor: holidayColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

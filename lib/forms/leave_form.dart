// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hris_mobile/components/snackbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LeaveRequestScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const LeaveRequestScreen({super.key, required this.user});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedLeaveType;

  final List<String> _leaveTypes = [
    'Sick Leave',
    'Vacation Leave',
    'Emergency Leave',
    'Maternity Leave',
    'Paternity Leave',
    'Bereavement Leave',
  ];

  Future<void> _pickDate({required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://192.168.99.139:3000/api/leave-request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employee_id': widget.user['id'],
          'leave_type': _selectedLeaveType,
          'start_date': _startDate!.toIso8601String().split('T')[0],
          'end_date': _endDate!.toIso8601String().split('T')[0],
        }),
      );

      if (response.statusCode == 200) {
        showCustomSnackBar(context, 'Leave request submitted! Status: Pending');
        setState(() {
          _startDate = null;
          _endDate = null;
          _selectedLeaveType = null;
        });
      } else {
        showCustomSnackBar(context, 'Failed to submit request');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Form', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromRGBO(109, 35, 35, 1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: () => _pickDate(isStart: true),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) =>
                        _startDate == null ? 'Please select a start date' : null,
                    controller: TextEditingController(
                      text: _startDate != null
                          ? DateFormat('yyyy-MM-dd').format(_startDate!)
                          : '',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _pickDate(isStart: false),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) =>
                        _endDate == null ? 'Please select an end date' : null,
                    controller: TextEditingController(
                      text: _endDate != null
                          ? DateFormat('yyyy-MM-dd').format(_endDate!)
                          : '',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Leave Type
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Type of Leave',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Select leave type'),
                items: _leaveTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                value: _selectedLeaveType,
                onChanged: (value) {
                  setState(() {
                    _selectedLeaveType = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a leave type' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(109, 35, 35, 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _submitForm,
                child: const Text(
                  'Submit',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hris_mobile/forms/leave_form.dart';
import 'package:hris_mobile/forms/payroll_form.dart';
import 'package:hris_mobile/forms/employment_form.dart';
import 'package:hris_mobile/components/snackbar.dart';

class RequestScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const RequestScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> requestCategories = [
      {
        'title': 'Leave Request',
        'subtitle': 'Click to submit a new request',
        'iconPath': 'assets/icons/form.svg', // Assuming a generic form icon
      },
      {
        'title': 'Payroll and Remittance Request',
        'subtitle': 'Click to submit a new request',
        'iconPath': 'assets/icons/payroll.svg', // Assuming a payroll icon
      },
      {
        'title': 'Attendance Rectification',
        'subtitle': 'Click to submit a new request',
        'iconPath': 'assets/icons/attendance.svg', // Assuming an attendance icon
      },
       {
        'title': 'Human Resources Management Services Request',
        'subtitle': 'Click to submit a new request',
        'iconPath': 'assets/icons/user.svg', // Assuming a user/HR icon
      },
    ];

    void handleCategoryTap(String category) {
      if (category == 'Leave Request') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LeaveRequestScreen(user: user)),
        );
      } else if (category == 'Payroll and Compensation Request') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PayrollFormScreen()),
        );
      } else if (category == 'Attendance Rectification') {
         // Navigate to Attendance Rectification form if available
         showCustomSnackBar(context, 'Attendance Rectification clicked (Form not implemented)');
      } else if (category == 'Employment and Documentation Request') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EmploymentFormScreen()),
        );
      } else {
        showCustomSnackBar(context, '$category clicked');
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(109, 35, 35, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Request Categories', style: TextStyle(color: Colors.white)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(109, 35, 35, 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${user['f_name']} ${user['l_name']}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text('HRIS User', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ...requestCategories.map((categoryData) {
              return ListTile(
                leading: SvgPicture.asset(
                  categoryData['iconPath']!,
                  width: 24,
                  height: 24,
                  color: const Color.fromRGBO(109, 35, 35, 1),
                ),
                title: Text(
                  categoryData['title']!,
                  style: const TextStyle(
                    color: Color.fromRGBO(109, 35, 35, 1),
                  ),
                ),
                subtitle: Text(
                  categoryData['subtitle']!,
                  style: TextStyle(
                    color: const Color.fromRGBO(109, 35, 35, 1).withOpacity(0.8),
                    fontSize: 12.0,
                  ),
                ),
                tileColor: const Color.fromRGBO(229, 208, 172, 1),
                onTap: () {
                  Navigator.pop(context);
                  handleCategoryTap(categoryData['title']!);
                },
              );
            }),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: requestCategories.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final categoryData = requestCategories[index];
          return Card(
            color: const Color.fromRGBO(229, 208, 172, 1),
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: ListTile(
              leading: SvgPicture.asset(
                categoryData['iconPath']!,
                width: 28,
                height: 28,
                color: const Color.fromRGBO(109, 35, 35, 1),
              ),
              title: Text(
                categoryData['title']!,
                style: const TextStyle(
                  color: Color.fromRGBO(109, 35, 35, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                categoryData['subtitle']!,
                style: TextStyle(
                  color: const Color.fromRGBO(109, 35, 35, 1).withOpacity(0.8),
                  fontSize: 12.0,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Color.fromRGBO(109, 35, 35, 1), size: 18.0),
              onTap: () => handleCategoryTap(categoryData['title']!),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            ),
          );
        },
      ),
    );
  }
}

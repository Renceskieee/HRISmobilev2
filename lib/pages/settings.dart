// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:hris_mobile/components/snackbar.dart';

class SettingsPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final void Function(Map<String, dynamic>) onProfileUpdated;

  const SettingsPage({super.key, required this.user, required this.onProfileUpdated});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController fNameController;
  late TextEditingController lNameController;
  late TextEditingController emailController;
  late TextEditingController usernameController;
  late TextEditingController employeeNoController;
  late TextEditingController roleController;
  late TextEditingController createdAtController;

  XFile? _image;
  String profileUrl = '';

  @override
  void initState() {
    super.initState();
    fNameController = TextEditingController();
    lNameController = TextEditingController();
    emailController = TextEditingController();
    usernameController = TextEditingController();
    employeeNoController = TextEditingController();
    roleController = TextEditingController();
    createdAtController = TextEditingController();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final res = await http.get(Uri.parse('http://192.168.99.139:3000/api/users/${widget.user['id']}'));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final dateTime = DateTime.tryParse(data['created_at']);
      final formattedDate = dateTime != null
          ? DateFormat('yyyy-MM-dd, HH:mm').format(dateTime)
          : data['created_at'];

      setState(() {
        fNameController.text = data['f_name'];
        lNameController.text = data['l_name'];
        emailController.text = data['email'];
        usernameController.text = data['username'];
        employeeNoController.text = data['employee_number'];
        roleController.text = data['role'];
        createdAtController.text = formattedDate;
        profileUrl = 'http://192.168.99.139:3000/uploads/${data['p_pic']}';
      });
    }
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = picked;
      });
    }
  }

  Future<void> updateProfile() async {
    var uri = Uri.parse('http://192.168.99.139:3000/api/users/${widget.user['id']}');
    var request = http.MultipartRequest('PUT', uri);

    request.fields['f_name'] = fNameController.text;
    request.fields['l_name'] = lNameController.text;

    if (_image != null) {
      if (kIsWeb) {
        final bytes = await _image!.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('p_pic', bytes, filename: _image!.name));
      } else {
        request.files.add(await http.MultipartFile.fromPath('p_pic', _image!.path));
      }
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      final updatedResponse = await http.get(uri);
      final updatedUser = jsonDecode(updatedResponse.body);
      widget.onProfileUpdated(updatedUser);

      showCustomSnackBar(context, 'Profile updated');
    } else {
      showCustomSnackBar(context, 'Update failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'User Profile',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _image != null
                          ? (kIsWeb
                              ? NetworkImage(_image!.path)
                              : FileImage(File(_image!.path)) as ImageProvider)
                          : (profileUrl.isNotEmpty ? NetworkImage(profileUrl) : null),
                      child: (_image == null && profileUrl.isEmpty)
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    InkWell(
                      onTap: pickImage,
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color.fromRGBO(163, 29, 29, 1),
                        child: Icon(Icons.edit, size: 16, color: Color.fromRGBO(255, 255, 255, 1)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              buildRoundedTextField(controller: fNameController, label: 'First Name', enabled: false),
              const SizedBox(height: 10),
              buildRoundedTextField(controller: lNameController, label: 'Last Name', enabled: false),
              const SizedBox(height: 10),
              buildRoundedTextField(controller: emailController, label: 'Email', enabled: false),
              const SizedBox(height: 10),
              buildRoundedTextField(controller: usernameController, label: 'Username', enabled: false),
              const SizedBox(height: 10),
              buildRoundedTextField(controller: employeeNoController, label: 'Employee Number', enabled: false),
              const SizedBox(height: 10),
              buildRoundedTextField(controller: roleController, label: 'Role', enabled: false),
              const SizedBox(height: 10),
              buildRoundedTextField(controller: createdAtController, label: 'Created At', enabled: false),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(163, 29, 29, 1),
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                ),
                onPressed: updateProfile,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRoundedTextField({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade300,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.black),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}

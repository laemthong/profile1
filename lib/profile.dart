import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  Map<String, dynamic>? profileData;

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.41/test6/get_profile.php?user_id=keys1805'), // เปลี่ยนเป็นที่อยู่เซิร์ฟเวอร์ของคุณ
    );

    print('Response body: ${response.body}'); // เพิ่มการแสดงผล response body

    if (response.statusCode == 200) {
      try {
        setState(() {
          profileData = json.decode(response.body);
        });
      } catch (e) {
        print('Error parsing JSON: $e');
      }
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _navigateAndEditProfile(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage(profileData: profileData!)),
    );

    if (result == true) {
      fetchProfileData(); // รีเฟรชข้อมูลหลังจากที่กลับมาจากการแก้ไข
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 0, 0, 0)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: profileData == null
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 50),
                  GestureDetector(
                    onTap: _pickImage,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: _image != null
                          ? Image.file(
                              _image!,
                              height: 120.0,
                              width: 120.0,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'images/P002.jpg',
                              height: 200.0,
                              width: 120.0,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    profileData!['user_name'] ?? 'Unknown',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('@${profileData!['user_id']}', style: TextStyle(color: Colors.grey[700])),
                  SizedBox(height: 8),
                  Text(profileData!['user_text'] != null ? ' ${profileData!['user_text']}' : ' Unknown'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        side: BorderSide(color: Colors.black),
                      ),
                    ),
                    onPressed: () => _navigateAndEditProfile(context),
                    child: Text('แก้ไขข้อมูล'),
                  ),
                ],
              ),
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profileData;

  EditProfilePage({required this.profileData});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _idController;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profileData['user_name'] ?? '');
    _idController = TextEditingController(text: widget.profileData['user_id'] ?? '');
    _textController = TextEditingController(text: widget.profileData['user_text']?.toString() ?? '');
  }

  Future<void> _saveProfile() async {
    final response = await http.post(
      Uri.parse('http://192.168.1.41/test6/update_profile.php'), // เปลี่ยนเป็นที่อยู่เซิร์ฟเวอร์ของคุณ
      body: {
        'user_id': widget.profileData['user_id'] ?? '',
        'user_name': _nameController.text,
        'user_text': _textController.text,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        widget.profileData['user_name'] = _nameController.text;
        widget.profileData['user_text'] = _textController.text;
      });
      Navigator.pop(context, true); // ส่งค่ากลับไปเพื่อรีเฟรชข้อมูลใน ProfilePage
    } else {
      throw Exception('Failed to update profile data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('แก้ไขข้อมูลโปรไฟล์'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  'แก้ไขข้อมูลโปรไฟล์',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'ชื่อ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: 'รหัสผู้ใช้',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.perm_identity),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'ข้อความ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.text_fields),
                ),
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: Text('บันทึก'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

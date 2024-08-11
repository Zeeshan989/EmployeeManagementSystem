import 'dart:convert';
import 'dart:typed_data';
import 'package:ems/Manage.dart';
import 'package:ems/signin.dart';
import 'package:ems/userinfo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ems/globals.dart' as globals;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
typedef PeopleCallback = Future<void> Function();

class People extends StatefulWidget {
  @override
  _PeoplePageState createState() => _PeoplePageState();
}

class _PeoplePageState extends State<People> {
  List<Map<String, dynamic>> users = [];
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    getallusersinfo();
    _searchController.addListener(_filterUsers);
  }

  Future<void> getallusersinfo() async {
    print('GETTING USERS');
    var url = Uri.parse('http://192.168.10.7:8000/api/v1/users/getallusers');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        // Debugging: Print the raw response body
        print('Response Body: ${response.body}');

        // Attempt to parse the JSON response
        var data = jsonDecode(response.body);

        // Check if the parsed data is a list
        if (data is List) {
          users = List<Map<String, dynamic>>.from(data);
          _filteredUsers = users;
          print('All users: $users');
        } else if (data is Map<String, dynamic> && data.containsKey('users')) {
          users = List<Map<String, dynamic>>.from(data['users']);
          _filteredUsers = users;
          print('All users: $users');
        } else {
          // Handle unexpected data format
          print('Unexpected data format: $data');
        }
      } else {
        print('Error: Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error parsing response: $e');
    }

    setState(() {});
  }

  void _filterUsers() {
    String sc = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = users.where((user) {
        final email = user['email']?.toLowerCase() ?? '';
        final middlename = user['middlename']?.toLowerCase() ?? '';
        final lastname = user['lastname']?.toLowerCase() ?? '';

        return email.contains(sc) || middlename.contains(sc) || lastname.contains(sc);
      }).toList();
    });
  }

  Future<void> logout() async {
    var url = Uri.parse('http://192.168.10.3:8000/api/v1/users/logout');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${globals.globalaccessToken}',
      },
    );
    var leres = jsonDecode(response.body) as Map<String, dynamic>;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(leres['message']),
        duration: Duration(seconds: 1),
      ),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      globals.globalaccessToken = '';
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SigninPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double searchBarWidth = screenWidth * 0.60;
    final double otherContentWidth = screenWidth * 0.25;
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: Text('ZESH-EMS'),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(globals.globaluser["avatar"]),
            ),
          ),
          TextButton(onPressed: logout, child: Text('LOGOUT'))
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 1, 83, 165),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(globals.globaluser["avatar"]),
                  radius: 20,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('People'),
            ),
            ListTile(
              leading: Icon(Icons.file_copy),
              title: Text('Manage Employee Assignments'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Manage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  color: Color.fromARGB(255, 1, 83, 165),
                  height: 120,
                  width: double.infinity,
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(globals.globaluser["avatar"]),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${globals.globaluser["middlename"]} ${globals.globaluser["lastname"]}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${globals.globaluser["Designation"]}",
                        style: TextStyle(
                            color: Color.fromARGB(255, 250, 244, 244),
                            fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'People',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: searchBarWidth,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by name, email, etc.',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 20),
                              fillColor: Colors.grey[200],
                            ),
                          ),
                        ),
                        SizedBox(
                            width:
                                8), // Add some space between the search bar and the other content
                        Container(
                          width: otherContentWidth,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue, // Background color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AddUserDialog(onUpdateUsers:getallusersinfo);
                                },
                              );
                            },
                            child: Text(
                              '+',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 500, // Set a fixed height for the ListView
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _filteredUsers.length, // Number of items in the ListView
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];

                          // Ensure the user has necessary data to display
                          if (user != null &&
                              user.isNotEmpty &&
                              user['firstname'] != null) {
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                width: 80, // Fixed width for each item
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          user['avatar'] ?? ''),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${user['firstname'] ?? ''}  - (${user['Designation'] ?? 'N/A'})',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(Icons.email,
                                                  size: 16,
                                                  color: Colors.grey),
                                              SizedBox(width: 5),
                                              Text(user['email'] ?? 'N/A',style: TextStyle(fontSize: 9),),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(Icons.phone,
                                                  size: 16,
                                                  color: Colors.grey),
                                              SizedBox(width: 5),
                                              Text(user['Phone'] ?? 'N/A',style: TextStyle(fontSize: 9)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                        'Reports To: ${user['ReportsTo'] ?? 'N/A'}'),
                                    SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            // Skip rendering if the user data is incomplete or null
                            return SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AddUserDialog extends StatefulWidget {
  final PeopleCallback onUpdateUsers;
   AddUserDialog({required this.onUpdateUsers});
  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _middlenameController = TextEditingController();
  final _lastnameController = TextEditingController();
  String? _designation;
  String? _gender;
  String? _maritalStatus;
  final empno = TextEditingController();
  final phoneController = TextEditingController();

  Uint8List? _selectedFileBytes;
  String? _selectedFileName;

  Future<void> pickFile() async {
    try {
      if (await Permission.storage.request().isGranted) {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          final fileBytes = await pickedFile.readAsBytes();
          setState(() {
            _selectedFileBytes = fileBytes;
            _selectedFileName = pickedFile.name;
          });

          print('File selected: $_selectedFileName');
          print('File bytes length: ${_selectedFileBytes?.length}');
        } else {
          print('File picking canceled');
        }
      } else {
        print('Storage permission not granted');
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _signup() async {
    print('Inside Signup');
    if (_selectedFileBytes == null) {
      print('No file selected');
      return;
    }

    print('Username: ${_usernameController.text}');
    print('Email: ${_emailController.text}');
    print('Password: ${_passwordController.text}');
    print('First Name: ${_firstnameController.text}');
    print('Middle Name: ${_middlenameController.text}');
    print('Last Name: ${_lastnameController.text}');
    print('Gender: $_gender');
    print('Marital Status: $_maritalStatus');
    print('Designation: $_designation');
    print('Employee No: ${empno.text}');
    print('Phone: ${phoneController.text}');
    print('Selected File Name: $_selectedFileName');
    print('Selected File Length: ${_selectedFileBytes?.length}');

    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _firstnameController.text.isEmpty ||
        _lastnameController.text.isEmpty ||
        _gender == null ||
        _maritalStatus == null ||
        _designation == null ||
        empno.text.isEmpty ||
        phoneController.text.isEmpty) {
      print('One or more fields are empty or null');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all the required fields'),
        ),
      );
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.10.7:8000/api/v1/users/register'),
      );

      request.fields['username'] = _usernameController.text;
      request.fields['email'] = _emailController.text;
      request.fields['password'] = _passwordController.text;
      request.fields['firstname'] = _firstnameController.text;
      request.fields['middlename'] = _middlenameController.text;
      request.fields['lastname'] = _lastnameController.text;
      request.fields['Gender'] = _gender!;
      request.fields['MartialStatus'] = _maritalStatus!;
      request.fields['Designation'] = _designation!;
      request.fields['EmployeeNo'] = empno.text;
      request.fields['Phone'] = phoneController.text;

      var file = http.MultipartFile.fromBytes(
        'avatar',
        _selectedFileBytes!,
        filename: _selectedFileName,
      );

      request.files.add(file);

      var streamedresponse = await request.send();
      var response = await http.Response.fromStream(streamedresponse);
      var deres = jsonDecode(response.body) as Map<String, dynamic>;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(deres['message']),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        widget.onUpdateUsers();
        
        setState(() {
          
        });
        Navigator.of(context).pop();
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Error during signup: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred during signup'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New User',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _firstnameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _middlenameController,
                decoration: InputDecoration(
                  labelText: 'Middle Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _lastnameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: empno,
                decoration: InputDecoration(
                  labelText: 'Employee #',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone #',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Choose Avatar: '),
                  ElevatedButton(
                    onPressed: pickFile,
                    child: Text('Pick Avatar'),
                  ),
                  if (_selectedFileBytes != null)
                    IconButton(icon: Icon(Icons.done), onPressed: () {})
                ],
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Designation',
                  border: OutlineInputBorder(),
                ),
                value: _designation,
                items: ['Admin', 'Manager', 'Employee']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _designation = value;
                  });
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                value: _gender,
                items: ['Male', 'Female']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Marital Status',
                  border: OutlineInputBorder(),
                ),
                value: _maritalStatus,
                items: ['Single', 'Married']
                    .map((label) => DropdownMenuItem(
                          child: Text(label),
                          value: label,
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _maritalStatus = value;
                  });
                },
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _signup,
                    child: Text('Create User'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

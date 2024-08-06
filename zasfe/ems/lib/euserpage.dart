import 'dart:convert';

import 'package:ems/People.dart';
import 'package:ems/etasks.dart';
import 'package:ems/signin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ems/globals.dart' as globals;

class EuserInfoPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<EuserInfoPage> {
  var username = '';
  var avatarUrl = '';
  var email = '';
  var firstname = '';
  var middlename = '';
  var lastname = '';
  var empno = '';
  var gender = '';
  var status = '';
  var designation = '';
  var phon = '';
  dynamic managerinfo;

  final _firstnameController = TextEditingController();
  final _middlenameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _empnoController = TextEditingController();
  final _genderController = TextEditingController();
  final _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getinfo();
  }

  Future<void> getemployeemanage() async {
    print('GETTING INFO'); // Check if this prints
    try {
      var url = Uri.parse(
          'http://192.168.10.5:8000/api/v1/users/getemployeemanager');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employee': globals.globaluser, // Ensure you pass the correct identifier
        }),
      );

      if (response.statusCode == 200) {
        print('Request successful');
        var man = jsonDecode(response.body);
        print('MO:${man}');
        setState(() {
          managerinfo = man; // Set the manager info here
        });
        print('MOM:${managerinfo['firstname']}');
        // Handle successful response
      } else {
        print('Request failed with status: ${response.statusCode}');
        // Handle different status codes
      }
    } catch (e) {
      print('Error in getemployeemanager: $e');
    }
  }

  Future<void> getinfo() async {
    var url = Uri.parse('http://192.168.10.5:8000/api/v1/users/userinfo');
    var response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${globals.globalaccessToken}',
      },
    );
    var usinfo = jsonDecode(response.body) as Map<String, dynamic>;
    globals.globaluser = usinfo;
    setState(() {
      username = usinfo['username'] ?? '';
      avatarUrl = usinfo["avatar"] ?? 'https://via.placeholder.com/150';
      email = usinfo["email"] ?? '';
      firstname = usinfo["firstname"] ?? '';
      middlename = usinfo["middlename"] ?? '';
      lastname = usinfo["lastname"] ?? '';
      empno = usinfo["EmployeeNo"] ?? '';
      gender = usinfo["Gender"] ?? '';
      status = usinfo["MartialStatus"] ?? '';
      designation = usinfo["Designation"] ?? '';
      phon = usinfo["Phone"] ?? '';

      _firstnameController.text = firstname;
      _middlenameController.text = middlename;
      _lastnameController.text = lastname;
      _empnoController.text = empno;
      _genderController.text = gender;
      _statusController.text = status;

      // Already in Celsius
    });
    getemployeemanage();
  }

  Future<void> logout() async {
    print('InsideLogout');
    var url = Uri.parse('http://192.168.10.5:8000/api/v1/users/logout');
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
    return Scaffold(
      appBar: AppBar(
        title: Text('ZESH-EMS'),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(avatarUrl),
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
                  backgroundImage: NetworkImage(avatarUrl),
                  radius: 20,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EuserInfoPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Tasks'),
              onTap: () {
                 Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>Etask()),
      );
              },
            ),
            ListTile(
              leading: Icon(Icons.file_copy),
              title: Text('Files'),
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
                  height: 250,
                  width: double.infinity,
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(avatarUrl),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "${middlename} ${lastname}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${designation}",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 150,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "${phon}",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.email, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            '${email}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                    
                      SizedBox(height: 8),
                    ],
                  ),
                ),
                // Manager info displayed on the right
                Positioned(
                  top: 170,
                  right: 20,
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text('REPORTS TO:',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w900,color: Color.fromARGB(255, 197, 115, 115)),),
                      managerinfo != null && managerinfo['avatar'] != null
                          ? CircleAvatar(
                              radius: 15,
                              backgroundImage:
                                  NetworkImage(managerinfo['avatar']),
                            )
                          : CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                  'https://via.placeholder.com/150'),
                            ),
                        ]
                      ),
                      Text(
                        '${managerinfo != null ? managerinfo['firstname'] ?? '' : ''} '
                        '${managerinfo != null ? managerinfo['middlename'] ?? '' : ''} '
                        ,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Personal',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Basic Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _empnoController,
                          decoration: InputDecoration(labelText: 'Employee #'),
                          readOnly: true,
                          enabled: false,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _firstnameController,
                          decoration: InputDecoration(labelText: 'First Name'),
                          readOnly: true,
                          enabled: false,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _middlenameController,
                          decoration: InputDecoration(labelText: 'Middle Name'),
                          readOnly: true,
                          enabled: false,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _lastnameController,
                          decoration: InputDecoration(labelText: 'Last Name'),
                          readOnly: true,
                          enabled: false,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: '12/06/1999',
                          decoration: InputDecoration(labelText: 'Birth Date'),
                          readOnly: true,
                          enabled: false,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _genderController,
                          decoration: InputDecoration(labelText: 'Gender'),
                          enabled: false,
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _statusController,
                          decoration: InputDecoration(labelText: 'Marital Status'),
                          enabled: false,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    initialValue: 'XXXXXXXXX',
                    decoration: InputDecoration(labelText: 'National ID'),
                    readOnly: true,
                    enabled: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

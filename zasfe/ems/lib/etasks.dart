import 'dart:convert';
import 'package:ems/signin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ems/globals.dart' as globals;
import 'package:http/http.dart' as http;

class Etask extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TaskAssignmentScreen(),
    );
  }
}

class TaskAssignmentScreen extends StatefulWidget {
  @override
  _TaskAssignmentScreenState createState() => _TaskAssignmentScreenState();
}

class _TaskAssignmentScreenState extends State<TaskAssignmentScreen> {
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescriptionController = TextEditingController();
  final List<String> _milestones = [];
  final TextEditingController _milestoneController = TextEditingController();
  Map<String, dynamic>? _selectedEmployee;
  DateTime? _selectedDeadline;
  dynamic tasksdata = [];

  @override
  void initState() {
    super.initState();
    gettasks();
  }

  Future<void> gettasks() async {
    var url = Uri.parse('http://192.168.10.5:8000/api/v1/users/gettaskes');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'assto': globals.globaluser, // Ensure you pass the correct identifier
      }),
    );
    print(response.statusCode);
    var gettasks = jsonDecode(response.body);
    print('TASKS  :${gettasks}');
    setState(() {
      tasksdata = gettasks;
    });
  }

  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskDescriptionController.dispose();
    _milestoneController.dispose();
    super.dispose();
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
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assignments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 1, 83, 165),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(globals.globaluser["avatar"]),
            ),
          ),
          TextButton(
            onPressed: logout,
            child: Text('LOGOUT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 30),
              tasksdata.isEmpty
                  ? Center(
                      child: Text(
                        'No Tasks Available',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    )
                  : _buildTasksList(screenSize),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
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
                    backgroundImage: NetworkImage(globals.globaluser['avatar']),
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
                        "${globals.globaluser['middlename']} ${globals.globaluser['lastname']}",
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${globals.globaluser['Designation']}",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                       Text(
                        "Assigned Tasks:  ${tasksdata.length}",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                     
                    ],
                  ),
                ),
                
              ],
            );
  }

  Widget _buildTasksList(Size screenSize) {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: tasksdata.length, // Number of items in the ListView
        itemBuilder: (context, index) {
          // Parse the date string and format it
          DateTime deadlineDate = DateTime.parse(tasksdata[index]['Deadline']);
          String formattedDate =
              DateFormat('EEEE, MMMM d, y').format(deadlineDate);

          return Card(
            elevation: 6, // Card shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${tasksdata[index]['Title']}',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 8),
                  
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Deadline:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle button press
                      },
                      child: Text(
                        'View Details',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent, // Button color
                        foregroundColor: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

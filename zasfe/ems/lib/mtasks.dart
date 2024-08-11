import 'dart:convert';
import 'package:ems/signin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ems/globals.dart' as globals;
import 'package:http/http.dart' as http;

class MyTeam extends StatefulWidget {
  @override
  _MyTeamState createState() => _MyTeamState();
}

class _MyTeamState extends State<MyTeam> {
  List<dynamic> etom = [];

  @override
  void initState() {
    super.initState();
    manageremployees(globals.globaluser);
  }

  Future<void> manageremployees(dynamic sup) async {
    var url = Uri.parse('http://192.168.10.7:8000/api/v1/users/getmanageremp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'supervisor': sup['_id'], // Ensure you pass the correct identifier
      }),
    );
    var memp = jsonDecode(response.body);
    setState(() {
      etom = memp['subordinates']; // Set loading to false once data is fetched
    });
  }

  Future<void> logout() async {
    print('InsideLogout');
    var url = Uri.parse('http://192.168.10.7:8000/api/v1/users/logout');
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
        title: Text('My Team', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            SizedBox(height: 10),
            const Center(
              child: Text(
                'Team',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 16),
            etom.isEmpty
                ? Center(
                    child: Text(
                      'No Employees Available',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  )
                : _buildEmployeeList(screenSize),
            SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MTasks()),
                  );
                },
                child: Text('ASSIGN TASK'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 

  Widget _buildEmployeeList(Size screenSize) {
    return Container(
      height: screenSize.height * 0.30, // Responsive height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: etom.length, // Number of items in the ListView
        itemBuilder: (context, index) {
          return 
            Container(
              width: screenSize.width * 0.3, // Responsive width
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(etom[index]['avatar']),
                    radius: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${etom[index]['firstname']} ${etom[index]['middlename']} ${etom[index]['lastname']}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                 
                ],
              ),
            );
          
        },
      ),
    );
  }
}



class MTasks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Add New Task',
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
  List<Map<String, dynamic>> mempdata = [];

  @override
  void initState() {
    super.initState();
    manageremployees(globals.globaluser);
  }

  Future<void> manageremployees(dynamic sup) async {
    var url = Uri.parse('http://192.168.10.7:8000/api/v1/users/getmanageremp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'supervisor': sup['_id'], // Ensure you pass the correct identifier
      }),
    );
    var memp = jsonDecode(response.body);
    setState(() {
      mempdata = List<Map<String, dynamic>>.from(memp['subordinates']);
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
    var url = Uri.parse('http://192.168.10.7:8000/api/v1/users/logout');
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
        title: Text('Task Assignment', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
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
              
              SizedBox(height: 30),
              Text(
                'Add New Task',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              _buildTaskTitleField(),
              SizedBox(height: 16.0),
              _buildTaskDescriptionField(),
              SizedBox(height: 16.0),
              _buildMilestonesField(),
              SizedBox(height: 16.0),
              _buildAssignToField(),
              SizedBox(height: 16.0),
              _buildDeadlineField(),
              SizedBox(height: 16.0),
              Center(
                child: TextButton(
                  onPressed: _submitTask,
                  child: Text('ADD NEW TASK'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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

 

  Widget _buildTaskTitleField() {
    return TextField(
      controller: _taskTitleController,
      decoration: InputDecoration(
        labelText: 'Task Title',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildTaskDescriptionField() {
    return TextField(
      controller: _taskDescriptionController,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: 'Task Description',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildMilestonesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestones',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        ..._milestones.map((milestone) => ListTile(
              title: Text(milestone),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _milestones.remove(milestone);
                  });
                },
              ),
            )),
        TextField(
          controller: _milestoneController,
          decoration: InputDecoration(
            hintText: 'Enter a milestone',
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (_milestoneController.text.isNotEmpty) {
                  setState(() {
                    var milestone=_milestoneController.text;
                    
                    _milestones.add(milestone);
                    _milestoneController.clear();
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssignToField() {
    return DropdownButtonFormField<Map<String, dynamic>>(
      decoration: InputDecoration(
        labelText: 'Assign To',
        border: OutlineInputBorder(),
      ),
      value: _selectedEmployee,
      items: mempdata.map((employee) {
        return DropdownMenuItem<Map<String, dynamic>>(
          value: employee,
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(
                    employee['avatar'] ?? 'https://via.placeholder.com/150'),
                radius: 12,
              ),
              SizedBox(width: 8), // Add some space between the avatar and the text
              Text('${employee['firstname']} ${employee['lastname']}'),
            ],
          ),
        );
      }).toList(),
      onChanged: (Map<String, dynamic>? value) {
        setState(() {
          _selectedEmployee = value;
        });
      },
    );
  }

  Widget _buildDeadlineField() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDeadline ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );

        if (pickedDate != null) {
          setState(() {
            _selectedDeadline = pickedDate;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDeadline != null
                  ? DateFormat('dd/MM/yyyy').format(_selectedDeadline!)
                  : 'Select Deadline',
              style: TextStyle(
                fontSize: 16.0,
                color: _selectedDeadline != null ? Colors.black : Colors.grey,
              ),
            ),
            Icon(Icons.calendar_today, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTask() async {
    var latestmilestones=[];
    for(int i=0;i<_milestones.length;i++){
      Map<String, String> milestoneMap = {
      'title':_milestones[i], // Unique identifier
     // Initial completion status
    };
    latestmilestones.add(milestoneMap );
    }
    try {
      print('INSIDE SUBMIT TASK');


      var url = Uri.parse('http://192.168.10.7:8000/api/v1/users/assignedtask');

      // Prepare the request body
      var requestBody = {
        'title': _taskTitleController.text,
        'description': _taskDescriptionController.text,
        'milestones': latestmilestones,
        'assignedtoid': _selectedEmployee?['_id'],
        'deadline': _selectedDeadline?.toIso8601String(), // Ensure proper date format
        'managerid': globals.globaluser['_id'],
      };

      print('Request Body: $requestBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var rb = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${rb['message']}'),
          ),
        );

        setState(() {
          _taskTitleController.clear();
          _taskDescriptionController.clear();
          _milestoneController.clear();
          _milestones.clear();
          _selectedEmployee = null;
          _selectedDeadline = null;
        });
      } else {
        // Handle non-200 responses
        print('Failed to submit task: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit task: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
        ),
      );
    }
  }
}

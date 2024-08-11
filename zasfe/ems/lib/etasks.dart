import 'dart:convert';
import 'package:ems/signin.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ems/globals.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

// Define the callback type
typedef ETasksCallback = Future<void> Function();
typedef RCallback = Future<void> Function();

class TaskPieChart extends StatelessWidget {
  final double percentageCompleted;

  TaskPieChart({required this.percentageCompleted});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // Ensures the pie chart is square
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 45,
          sections: _buildPieChartSections(),
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                return;
              }
              final touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
              // Handle touch interactions here
            },
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final completedValue = percentageCompleted;
    final pendingValue = 100 - percentageCompleted;

    return [
      PieChartSectionData(
        color: Colors.greenAccent[400],
        value: completedValue,
        title: '${completedValue.toStringAsFixed(1)}%',
        radius: 70,
        titleStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: _buildBadge(
          iconData: Icons.check_circle,
          color: Colors.greenAccent[700]!,
        ),
        badgePositionPercentageOffset: 1.2,
      ),
      PieChartSectionData(
        color: Colors.orangeAccent[400],
        value: pendingValue,
        title: '${pendingValue.toStringAsFixed(1)}%',
        radius: 70,
        titleStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: _buildBadge(
          iconData: Icons.pending,
          color: Colors.orangeAccent[700]!,
        ),
        badgePositionPercentageOffset: 1.2,
      ),
    ];
  }

  Widget _buildBadge({required IconData iconData, required Color color}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Icon(
        iconData,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}

class Etask extends StatelessWidget {
  final RCallback onUpdate;
  Etask({required this.onUpdate});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TaskAssignmentScreen(onUpdate: onUpdate),
    );
  }
}

class TaskAssignmentScreen extends StatefulWidget {
  final RCallback onUpdate; // Add this to the constructor
  TaskAssignmentScreen({required this.onUpdate}); // Constructor to accept the callback

  DateTime currentDate = DateTime.now();
  @override
  _TaskAssignmentScreenState createState() => _TaskAssignmentScreenState();
}

class _TaskAssignmentScreenState extends State<TaskAssignmentScreen> {
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescriptionController =
      TextEditingController();
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
    var url = Uri.parse('http://192.168.10.7:8000/api/v1/users/gettaskes');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'assto': globals.globaluser, // Ensure you pass the correct identifier
      }),
    );

    if (response.statusCode == 200) {
      var gettasks = jsonDecode(response.body);

      setState(() {
        tasksdata = gettasks;
      });

      widget.onUpdate();
    
    } else {
      print('Failed to load tasks. Status code: ${response.statusCode}');
    }

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
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assignments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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

  Widget _buildTasksList(Size screenSize) {
    // Sort tasks based on the deadline date
    tasksdata.sort((a, b) {
      DateTime deadlineA = DateTime.parse(a['Deadline']);
      DateTime deadlineB = DateTime.parse(b['Deadline']);
      return deadlineA.compareTo(deadlineB); // Sorts in ascending order
    });

    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemCount: tasksdata.length, // Number of items in the ListView
        itemBuilder: (context, index) {
          // Parse the date string and format it
          DateTime deadlineDate = DateTime.parse(tasksdata[index]['Deadline']);
          Duration difference = deadlineDate.difference(widget.currentDate);
          int daysBetween = difference.inDays;

          String formattedDate =
              DateFormat('EEEE, MMMM d, y').format(deadlineDate);
          double percentageCompleted =
              tasksdata[index]['Percentage'].toDouble();

          return Card(
            elevation: 8, // Increase elevation for a more modern look
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5), // Slightly wider margins
            child: Container(
              padding: const EdgeInsets.all(20.0), // Slightly increased padding
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 6,
                    offset: Offset(0, 4), // Enhanced shadow for a floating effect
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
                      fontWeight: FontWeight.w900,
                      fontSize: 20, // Slightly larger font size
                    ),
                  ),
                  SizedBox(height: 10), // Space between title and next section
                  if (daysBetween < 0 && tasksdata[index]['Complete']==false)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0), // Reduced top padding
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'OVERDUE',
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w900),
                        ),
                        style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 12.0)), // Reduced padding
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 8, 3, 97)),
                        ),
                      ),
                    ),
                      if (tasksdata[index]['Complete']==true)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0), // Reduced top padding
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'COMPLETED',
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w900),
                        ),
                        style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 12.0)), // Reduced padding
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 2, 94, 77)),
                        ),
                      ),
                    ),
                  if (daysBetween <= 2 && tasksdata[index]['Complete']==false)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0), // Reduced top padding
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'DUE IN ${daysBetween} DAY(S)',
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w900),
                        ),
                        style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 12.0)), // Reduced padding
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Color.fromARGB(255, 246, 3, 3)),
                        ),
                      ),
                    ),
                  SizedBox(height: 16), // Space before pie chart
                  TaskPieChart(percentageCompleted: percentageCompleted),
                  SizedBox(height: 16), // Space before legend
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(
                        color: Colors.green,
                        text: 'Milestones Achieved',
                      ),
                      SizedBox(width: 8), // Reduced space between legend items
                      _buildLegendItem(
                        color: Color.fromARGB(255, 241, 101, 36),
                        text: 'Pending Milestones',
                      ),
                    ],
                  ),
                  const Divider(),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8.0), // Reduced vertical padding
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TaskDetailScreen(
                                onUpdateTask: gettasks,
                                taskData: tasksdata[index]),
                          ),
                        );
                      },
                      child: Text(
                        'View Details',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
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

  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 18, // Slightly larger box width
          height: 18, // Slightly larger box height
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
        SizedBox(width: 10), // Space between box and text
        Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> taskData;
  final ETasksCallback onUpdateTask;

  TaskDetailScreen({required this.taskData, required this.onUpdateTask});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  List<Map<String, dynamic>> milestones = [];
  TextEditingController _commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    milestones = List<Map<String, dynamic>>.from(widget.taskData['Milestones']);
    _commentsController.text = widget.taskData['EmpComments'] ?? '';
  }

  void _toggleMilestoneCompletion(int index) {
    setState(() {
      milestones[index]['completed'] = !milestones[index]['completed'];
    });
  }

  Future<void> _saveChanges(id) async {
    int checkedmilestones = 0;
    for (int i = 0; i < milestones.length; i++) {
      if (milestones[i]['completed'] == true) {
        checkedmilestones = checkedmilestones + 1;
      }
    }
    var percentage = (checkedmilestones / milestones.length) * 100;
    print('Milestones: $milestones');
    print('Comments: ${_commentsController.text}');
    print('Percentage of work done: ${percentage.round()}');

    try {
      var url = Uri.parse(
          'http://192.168.10.7:8000/api/v1/users/getemployeemanagerbc');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Milestones': milestones,
          'Comments': _commentsController.text,
          'Percentage': percentage.round(),
          'TaskId': id, // Ensure you pass the correct identifier
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Changes saved successfully!'),
            duration: Duration(seconds: 2),
            backgroundColor: Color.fromARGB(255, 6, 97, 9),
            elevation: 6,
            behavior: SnackBarBehavior.floating, // Make it floating
            margin: EdgeInsets.only(
                top: 40.0, left: 10.0, right: 10.0), // Adjust the margin to position it
          ),
        );
        widget.onUpdateTask();
        Navigator.pop(context);
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save changes.'),
            duration: Duration(seconds: 2),
            backgroundColor: Color.fromARGB(255, 227, 43, 6),
          ),
        );
        widget.onUpdateTask();
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _undochanges(id) async {
    int checkedmilestones = 0;
    for (int i = 0; i < milestones.length; i++) {
      if (milestones[i]['completed'] == true) {
        checkedmilestones = checkedmilestones + 1;
      }
    }
    var percentage = (checkedmilestones / milestones.length) * 100;
    print('Milestones: $milestones');
    print('Comments: ${_commentsController.text}');
    print('Percentage of work done: ${percentage.round()}');

    try {
      var url = Uri.parse('http://192.168.10.7:8000/api/v1/users/undo');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Milestones': milestones,
          'Comments': _commentsController.text,
          'Percentage': percentage.round(),
          'TskId': id, // Ensure you pass the correct identifier
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Submission Undone'),
            duration: Duration(seconds: 2),
            backgroundColor: Color.fromARGB(255, 6, 97, 9),
            elevation: 6,
            behavior: SnackBarBehavior.floating, // Make it floating
            margin: EdgeInsets.only(
                top: 40.0, left: 10.0, right: 10.0), // Adjust the margin to position it
          ),
        );
        Navigator.pop(context);
        setState(() {
          widget.taskData['Complete'] == false;
        });
        widget.onUpdateTask();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save changes.'),
            duration: Duration(seconds: 2),
            backgroundColor: Color.fromARGB(255, 227, 43, 6),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _markcomplete(id) async {
    int checkedmilestones = 0;
    for (int i = 0; i < milestones.length; i++) {
      if (milestones[i]['completed'] == true) {
        checkedmilestones = checkedmilestones + 1;
      }
    }
    var percentage = (checkedmilestones / milestones.length) * 100;
    print('Milestones: $milestones');
    print('Comments: ${_commentsController.text}');
    print('Percentage of work done: ${percentage.round()}');

    try {
      var url = Uri.parse('http://192.168.10.7:8000/api/v1/users/done');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'TaskId': id,
          'Milestones': milestones,
          'Comments': _commentsController.text,
          'Percentage': percentage.round(),
          'TskId': id, // Ensure you pass the correct identifier // Ensure you pass the correct identifier
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('MARKED AS COMPLETE'),
            duration: Duration(seconds: 2),
            backgroundColor: Color.fromARGB(255, 6, 97, 9),
            elevation: 6,
            behavior: SnackBarBehavior.floating, // Make it floating
            margin: EdgeInsets.only(
                top: 40.0, left: 10.0, right: 10.0), // Adjust the margin to position it
          ),
        );
        setState(() {});
        widget.onUpdateTask();
         Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('NOT MARKED COMPLETE'),
            duration: Duration(seconds: 2),
            backgroundColor: Color.fromARGB(255, 227, 43, 6),
          ),
        );
        widget.onUpdateTask();
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: () {
              _saveChanges(widget.taskData['_id']); // ensure this is called
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              if(widget.taskData['Complete'])
                  Center(child: Text('MARKED AS COMPLETE',style:TextStyle(color:Colors.white,backgroundColor:Color.fromARGB(255, 4, 84, 11)),),),
               _buildTitleSection(),
              SizedBox(height: 20),
              _buildDescriptionSection(),
              SizedBox(height: 20),
              widget.taskData['Complete']
                  ? _buildafMilestonesSection()
                  : _buildMilestonesSection(),
              SizedBox(height: 20),
              widget.taskData['Complete']
                  ? _buildafCommentsSection()
                  : _buildCommentsSection(),
              SizedBox(height: 20),
              widget.taskData['Complete']
                  ? Row(children: [SizedBox(width: 2),_undosubmission()])
                  : Row(children: [_buildSaveChangesButton(),SizedBox(width: 20), _buildMarkButton()])
            ],
          ),
        ),
      ),
    );
  }

  Widget _submitted() {
    return Center(
      child: Text(
        'MARKED COMPLETE',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,backgroundColor:Color.fromARGB(255, 189, 4, 128),color: Colors.white),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Title',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextFormField(
          initialValue: widget.taskData['Title'],
          readOnly: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextFormField(
          initialValue: widget.taskData['Details'],
          readOnly: true,
          maxLines: 5,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildMilestonesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[900],
          ),
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: milestones.length,
          itemBuilder: (context, index) {
            final milestone = milestones[index];
            final isCompleted = milestone['completed'];

            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isCompleted ? Colors.green : Colors.red,
                  child: Icon(
                    isCompleted ? Icons.check : Icons.pending,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  milestone['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: isCompleted ? Colors.green : Colors.black,
                  ),
                ),
                subtitle: LinearProgressIndicator(
                  value: isCompleted ? 1.0 : 0.0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green : Colors.red,
                  ),
                ),
                trailing: Chip(
                  label: Text(
                    isCompleted ? 'Completed' : 'Pending',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor:
                      isCompleted ? Colors.green : Colors.red,
                ),
                onTap: () => _toggleMilestoneCompletion(index),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildafMilestonesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[900],
          ),
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: milestones.length,
          itemBuilder: (context, index) {
            final milestone = milestones[index];
            final isCompleted = milestone['completed'];

            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isCompleted ? Colors.green : Colors.red,
                  child: Icon(
                    isCompleted ? Icons.check : Icons.pending,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  milestone['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: isCompleted ? Colors.green : Colors.black,
                  ),
                ),
                subtitle: LinearProgressIndicator(
                  value: isCompleted ? 1.0 : 0.0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green : Colors.red,
                  ),
                ),
                trailing: Chip(
                  label: Text(
                    isCompleted ? 'Completed' : 'Pending',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor:
                      isCompleted ? Colors.green : Colors.red,
                ),
                onTap: () => {},
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _commentsController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Add your comments here...',
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildafCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextFormField(
          readOnly: true,
          controller: _commentsController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Add your comments here...',
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveChangesButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          _saveChanges(widget.taskData['_id']);
        },
        child: Text(
          'Save Changes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          shadowColor: Colors.blueAccent.withOpacity(0.5),
          elevation: 8,
        ),
      ),
    );
  }

  Widget _undosubmission() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          _undochanges(widget.taskData['_id']);
        },
        child: Text(
          'Undo Submission',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          shadowColor: Colors.blueAccent.withOpacity(0.5),
          elevation: 8,
        ),
      ),
    );
  }

  Widget _buildMarkButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          _markcomplete(widget.taskData['_id']);
        },
        child: Text(
          'MARK AS COMPLETE',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.greenAccent[400],
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          shadowColor: Colors.greenAccent.withOpacity(0.5),
          elevation: 8,
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:ems/People.dart';
import 'package:ems/etasks.dart';
import 'package:ems/signin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ems/globals.dart' as globals;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
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
        color: Color.fromARGB(255, 3, 52, 248),
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
          color:Color.fromARGB(255, 3, 52, 248),
        ),
        badgePositionPercentageOffset: 1.2,
      ),
      PieChartSectionData(
        color:Color.fromARGB(255, 140, 140, 142),
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
          color: Color.fromARGB(255, 140, 140, 142),
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
   dynamic tasks = [];
   double completedass=0;
  


  final _firstnameController = TextEditingController();
  final _middlenameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _empnoController = TextEditingController();
  final _genderController = TextEditingController();
  final _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
     gettasks();
    getinfo();
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
       tasks=gettasks;
      });

      percentagecalculation();
    } else {
      print('Failed to load tasks. Status code: ${response.statusCode}');
    }
  }
   Future<void> percentagecalculation() async {
    int count=0;
    for(int i=0;i<tasks.length;i++){
      if(tasks[i]['Complete']==true){
        count=count+1;
      }
    }
    setState(() {
      completedass=((count)/(tasks.length))*100;
      

    });
   
  }

  Future<void> getemployeemanage() async {
   
    try {
      var url = Uri.parse(
          'http://192.168.10.7:8000/api/v1/users/getemployeemanager');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'employee': globals.globaluser, // Ensure you pass the correct identifier
        }),
      );

      if (response.statusCode == 200) {
      
        var man = jsonDecode(response.body);
       
        setState(() {
          managerinfo = man; // Set the manager info here
        });
       
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
    var url = Uri.parse('http://192.168.10.7:8000/api/v1/users/userinfo');
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
        MaterialPageRoute(builder: (context) =>Etask(onUpdate:gettasks)),
      );
              },
            ),
            ListTile(
              leading: Icon(Icons.file_copy),
              title: Text('Request Timeoff'),



              onTap: () {
                                                   Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => Timeoff(

                                                            manager:managerinfo,

                                                          ),
                                                        ),
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
                          Text('REPORTS TO:',style: TextStyle(fontSize: 12,fontWeight: FontWeight.w900,color: Color.fromARGB(255, 255, 255, 255)),),
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
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _firstnameController,
                          decoration: InputDecoration(labelText: 'First Name'),
                          readOnly: true,
                          enabled: false,
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _middlenameController,
                          decoration: InputDecoration(labelText: 'Middle Name'),
                          readOnly: true,
                          enabled: false,
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _lastnameController,
                          decoration: InputDecoration(labelText: 'Last Name'),
                          readOnly: true,
                          enabled: false,
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [

                      SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _genderController,
                          decoration: InputDecoration(labelText: 'Gender'),
                          enabled: false,
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: TextFormField(
                          controller: _statusController,
                          decoration: InputDecoration(labelText: 'Marital Status'),
                          enabled: false,
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'TASKS STATUS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ), // Space before pie chart
           TaskPieChart(percentageCompleted: completedass),
           Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Column(               
                    children: [
                      _buildLegendItem(
                        color: Color.fromARGB(255, 1, 83, 165),
                        text: 'Completed Assignments',
                      ),
                      SizedBox(width: 8), // Reduced space between legend items
                      _buildLegendItem(
                        color:Color.fromARGB(255, 140, 140, 142),
                        text: 'Pending Assignments',
                      ),
                    ],
                  ),
                  ],),
                  SizedBox(height: 20),

          ],
        ),
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
class Timeoff extends StatefulWidget {
  final dynamic manager;
  Timeoff({required this.manager});
  @override
  _TimePageState createState() => _TimePageState();
}

class _TimePageState extends State<Timeoff> {
  dynamic pasttimeoffs = [];
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    getusertimeoffs();
  }

  Future<void> getusertimeoffs() async {
    print('GETTING TIMEOFFS');
    try {
      var url = Uri.parse('http://192.168.10.7:8000/api/v1/users/timeoff');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'requser': globals.globaluser,
        }),
      );
      var responsedata = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Response Timeoff: ${responsedata}');
        setState(() {
          pasttimeoffs = responsedata;
        });
      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error in requestimeoff: $e');
    }
  }

  Future<void> requestimeoff() async {
    if (startDate == null || endDate == null) {
      return;
    }
    try {
      var url = Uri.parse('http://192.168.10.7:8000/api/v1/users/reqtimebc');
      print('Request URL: $url');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'start': startDate!.toIso8601String(),
          'end': endDate!.toIso8601String(),
          'requser': globals.globaluser,
          'resuser': widget.manager,
          'status': 'pending',
        }),
      );
      var responsedata = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Request was successful');
        getusertimeoffs();
      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error in requestimeoff: $e');
    }
  }

  void _showDateRangePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Date Range'),
          content: Container(
            height: 400,
            width: 300,
            child: SfDateRangePicker(
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                setState(() {
                  if (args.value is PickerDateRange) {
                    startDate = args.value.startDate;
                    endDate = args.value.endDate;
                  }
                });
              },
              selectionMode: DateRangePickerSelectionMode.range,
              selectionColor: Colors.blueAccent,
              startRangeSelectionColor: Colors.greenAccent,
              endRangeSelectionColor: Colors.greenAccent,
              rangeSelectionColor: Colors.blue.withOpacity(0.3),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                requestimeoff();
              },
              child: Text('Request', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Past Timeoff Requests'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.0),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Past Timeoff Requests',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  pasttimeoffs.isEmpty
                      ? Center(child: Text('No past requests', style: TextStyle(color: Colors.grey, fontSize: 16)))
                      : DataTable(
                          columns: [
                            DataColumn(label: Text('From')),
                            DataColumn(label: Text('To')),
                            DataColumn(label: Text('Status')),
                          ],
                          rows: pasttimeoffs.map<DataRow>((timeoff) {
                            DateTime startDate = DateTime.parse(timeoff['StartDate']);
                            DateTime endDate = DateTime.parse(timeoff['EndDate']);
                            String formattedStartDate = DateFormat('dd MMM, yy').format(startDate);
                            String formattedEndDate = DateFormat('dd MMM, yy').format(endDate);
                            String status = timeoff['Status'];
                            Color statusColor;
                            switch (status.toLowerCase()) {
                              case 'approved':
                                statusColor = Colors.green;
                                break;
                              case 'rejected':
                                statusColor = Colors.red;
                                break;
                              default:
                                statusColor = Color.fromARGB(255, 2, 78, 255);
                                break;
                            }

                            return DataRow(cells: [
                              DataCell(Text(formattedStartDate)),
                              DataCell(Text(formattedEndDate)),
                              DataCell(Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                                ),
                              )),
                            ]);
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDateRangePickerDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 241, 4, 4),
      ),
    );
  }
}
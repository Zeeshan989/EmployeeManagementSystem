import 'dart:convert';
import 'dart:typed_data';
import 'package:ems/People.dart';
import 'package:ems/muserpage.dart';
import 'package:ems/signin.dart';
import 'package:ems/userinfo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ems/globals.dart' as globals;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
// Define the callback type
typedef ManagerCallback = Future<void> Function();


class Manage extends StatefulWidget {
  @override
  _PeoplePageState createState() => _PeoplePageState();
}

class _PeoplePageState extends State<Manage> {
  List managers = [];
  List employees=[];
 

  
  

  @override
  void initState() {
    super.initState();
    getallmanagersinfo();
    
  }

  Future<void> getallmanagersinfo() async {
    var url = Uri.parse('http://192.168.10.8:8000/api/v1/users/getmanagers');
    var response = await http.get(url);
    var managersdata = jsonDecode(response.body);
    setState(() {
      managers=managersdata;
      print('MANAGERS BULAO LMAO');
    });
    getallemployeesinfo();
  }



  Future<void> getallemployeesinfo() async {
    var url = Uri.parse('http://192.168.10.8:8000/api/v1/users/getemployees');
    var response = await http.get(url);
    var employeesdata = jsonDecode(response.body);
    setState(() {
      employees=employeesdata;
    });
   
  }
 
 

  Future<void> logout() async {
    var url = Uri.parse('http://192.168.10.8:8000/api/v1/users/logout');
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
    print('MANAGERS INFO :${managers} \n\n');
    
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
              onTap: (){
                MaterialPageRoute(builder: (context) =>UserInfoPage());
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('People'),
              onTap: (){
              MaterialPageRoute(builder: (context) =>People());
              },
            ),
             ListTile(
              leading: Icon(Icons.file_copy),
              title: Text('Manage Employee Assignments'),
              onTap: (){
              MaterialPageRoute(builder: (context) =>Manage());
                 
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
                     
                    ],
                  ),
                ),
                
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Managers',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                child: Column(children: [
                  Container(
                    height: 500, // Set a fixed height for the horizontal ListView
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: managers.length, // Number of items in the ListView
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              width: 40, // Fixed width for each item
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(managers[index]['avatar']!),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${managers[index]['firstname']} ${managers[index]['middlename']} ${managers[index]['lastname']}',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(Icons.email, size: 16, color: Colors.grey),
                                              SizedBox(width: 5),
                                              Text("Team members: ${managers[index]['numberOfSubordinates']}"),
                                            ],
                                          ),
                                          SizedBox(height: 5),
                                          
                                         
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                              TextButton(
                                                  onPressed: () {
                                                     Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => viewteam(
                                                              onUpdateManagers: getallmanagersinfo,
                                                              man:managers[index],
                                                              emp:employees,
                                                            ),
                                                          ),
                                                     );              
                                                  },
                                                  child: Text('View Team'),
                                                ),
                                              SizedBox(width: 10),
                                            ]
                              ),
                            ),
                          );
                        }
                    ),
                  ),
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class viewteam extends StatefulWidget {
  final dynamic man;
  final dynamic emp;
  final ManagerCallback onUpdateManagers;
  
  

  // Constructor with required parameters
  viewteam({required this.man, required this.emp,required this.onUpdateManagers});

  @override
  _viewteamState createState() => _viewteamState();
}
class _viewteamState extends State<viewteam> {
 
  dynamic totalemployees;
  dynamic managerdata; // Variable to store the selected dropdown value
  dynamic etom;
  bool isLoading = true; // Track loading state
  dynamic currentemp=[];

 

   @override
  void initState() {
    super.initState();
    totalemployees = widget.emp; 
    managerdata=widget.man;
    getemployonman(widget.man);

  }

  void showDropdown() {
  
  List<dynamic> selectedEmployees = []; // List to store selected employees
  


  showDialog(

    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Assign Employees'),
            content: Container(
              width: double.maxFinite, 
              height:double.maxFinite,// Ensures the dialog takes full width
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: totalemployees.length,
                itemBuilder: (context, index) {
                  final empl = totalemployees[index];
                  final isSelected = selectedEmployees.contains(empl);

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (bool? checked) {
                      setState(() {
                        if (checked == true) {
                          selectedEmployees.add(empl);
                        } else {
                          selectedEmployees.remove(empl);
                        }
                      });
                    },
                    title: Row(
                      children: [
                        CircleAvatar(
                  
                          backgroundImage: NetworkImage(empl["avatar"]),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '${empl['firstname']} ${empl['middlename']} ${empl['lastname']}',
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog without saving
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async{
                  currentemp=selectedEmployees;
                   await addassignee(currentemp,managerdata);

                   
                   
                  Navigator.of(context).pop(); // Close the dialog with selections
                  // Do something with the selected employees
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${selectedEmployees.length} employees assigned to ${managerdata['firstname']} ${managerdata['middlename']} ${managerdata['lastname']}'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Text('Done'),
              ),
            ],
          );
        },
      );
    },
  );
  }
  Future<void> addassignee(sub,sup) async {
          var url = Uri.parse('http://192.168.10.8:8000/api/v1/users/addassignee');
        final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'supervisor':sup,
              'subordinate':sub,
      }),
    );
    if(response.statusCode==200 || response.statusCode==201){
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 5,
          backgroundColor: Colors.green,
          content: Text('Added Successfully'),
          duration: Duration(seconds: 5),
        ),
      );
    setState(() {
      for(var i=0;i<sub.length;i++){
        etom.add(sub[i]);
      
      }
  
    for(int u=0;u<sub.length;u++){
     totalemployees.removeWhere((item) => item['_id'] == sub[u]['_id']);
    }
   


    });
     widget.onUpdateManagers();
    }

  }

Future<void> deleterelation(sup,sub) async {
  

    
        var url = Uri.parse('http://192.168.10.8:8000/api/v1/users/deleteassignee');
        final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'subordinate':sub,
      }),
    );
  
    if(response.statusCode==200 || response.statusCode==201){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 5,
          backgroundColor: Colors.green,
          content: Text('Removed User'),
          duration: Duration(seconds: 5),
        ),
      );
    setState(() {
      etom.removeWhere((item) => item['_id'] == sub['_id']);
      isLoading = false; // Set loading to false once data is fetched
      if(totalemployees.contains(sub)){
        print('Already in');
      }
      else{
        totalemployees.add(sub);
      }

   
   
      
    });
    }
    else{
      print('ERROR OCCURED');

    }
 

  }
  
  









  

  Future<void> getemployonman(dynamic sup) async {
  
    var url = Uri.parse('http://192.168.10.8:8000/api/v1/users/getmanageremp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'supervisor': sup['_id'], // Ensure you pass the correct identifier
      }),
    );
    var memp = jsonDecode(response.body);
    setState(() {
     etom=memp['subordinates'];
     isLoading = false; // Set loading to false once data is fetched
    });
  }
  
  @override
  Widget build(BuildContext context) {
    
     
  
     return Dialog(
      backgroundColor: Colors.transparent, // Makes the dialog background transparent
      insetPadding: EdgeInsets.all(10), // Reduces inset padding to make dialog larger
      child: Container(
        width: MediaQuery.of(context).size.width, // Full width
        height: MediaQuery.of(context).size.height, // Full height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Optional: rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            
            // Title Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${managerdata['firstname']} ${managerdata['lastname']} Team',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Avatar and Team Members Section
            Expanded(
              child: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(managerdata["avatar"]),
                      radius: 100,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '  Team Members',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    isLoading
            ? Text('Loading.....') // Show loading indicator while data is being fetched
             : Container(
                              height:
                                  500, // Set a fixed height for the horizontal ListView
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  itemCount:
                                      etom.length, // Number of items in the ListView
                                  itemBuilder: (context, index) {
                                    return Card(
                                      elevation: 6,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Container(
                                        width: 40, // Fixed width for each item
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                etom[index]
                                                    ['avatar']!),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${etom[index]['firstname']} ${etom[index]['middlename']} ${etom[index]['lastname']}',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          TextButton(onPressed:() async{
                                            
                                            deleterelation(managerdata,etom[index]);
                                            await widget.onUpdateManagers();}, child: Text('Remove'))
                                        ]),
                                      ),
                                    );
                                  },
                              ),
                          ), // 
                    // Additional details if needed
                  ],
                ),
              ),
            ),

            // Action Buttons Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                   showDropdown();
                  },
                  child: Text(
                    'Assign Employee(s)',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16), // Add some space at the bottom
          ],
        ),
      ),
    );
   
  }
}


   
 
import 'dart:convert';
import 'dart:typed_data';
import 'package:ems/signin.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _middlenameController = TextEditingController();
  final _lastnameController = TextEditingController();
  String? _designation;
  String? _gender;
  String? _maritalStatus;
  final empno=TextEditingController();
  final phoneController=TextEditingController();


  PlatformFile? _selectedFile;


  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _signup() async {
    if (_selectedFile == null) {
      // Handle the case where no file is selected
      print('No file selected');
      return;
    }

    
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.10.3:8000/api/v1/users/register'),
    );

    request.fields['username'] = _usernameController.text;
    request.fields['email'] = _emailController.text;
    request.fields['password'] = _passwordController.text;
    request.fields['firstname'] = _firstnameController.text;
    request.fields['middlename'] = _middlenameController.text;
    request.fields['lastname'] = _lastnameController.text;
    request.fields['Gender']=_gender!;
    request.fields['MartialStatus']=_maritalStatus!;
    request.fields['Designation']=_designation!;
    request.fields['EmployeeNo']=empno.text;
    request.fields['Phone']=phoneController.text;





    var file = http.MultipartFile.fromBytes(
      'avatar',
      _selectedFile!.bytes!,
      filename: _selectedFile!.name,
    );

    request.files.add(file);

    // Send the request
    var streamedresponse = await request.send();
    var response = await http.Response.fromStream(streamedresponse);
    var deres = jsonDecode(response.body) as Map<String, dynamic>;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(deres['message']),
        ),
      );
    
  
    if(response.statusCode==200 || response.statusCode==201){
      
      Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SigninPage()),
      );
    }
    else{
      

    }

    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signup')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
           child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _firstnameController,
                decoration: InputDecoration(labelText: 'FirstName',
                labelStyle: TextStyle(fontSize: 7),
                ),
                
              ),
              TextFormField(
                controller: _middlenameController,
                decoration: InputDecoration(labelText: 'MiddleName',
                labelStyle: TextStyle(fontSize: 7),),
              ),
              TextFormField(
                controller: _lastnameController,
                decoration: InputDecoration(labelText: 'LastName',
                labelStyle: TextStyle(fontSize: 7),),
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username',
                labelStyle: TextStyle(fontSize: 7),),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email',
                labelStyle: TextStyle(fontSize: 7),),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password',
                labelStyle: TextStyle(fontSize: 7),),
                obscureText: true,
              ),
               TextFormField(
                controller: empno,
                decoration: InputDecoration(labelText: 'Employee#',
                labelStyle: TextStyle(fontSize: 7),),
                obscureText: true,
              ),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone #',
                labelStyle: TextStyle(fontSize: 7),),
                obscureText: true,
              ),
              SizedBox(height: 20),
              Row(children: [
                Text('Choose Avatar : ',style: TextStyle(fontSize: 7)),
              ElevatedButton(
                onPressed: pickFile,
                child: Text('Pick Avatar: ',style: TextStyle(fontSize: 7)),
              ),
              if (_selectedFile != null) 
                Text('Selected File: ${_selectedFile!.name}'),
              

              ]),
              SizedBox(height: 20),
             
              DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Designation',
                border: OutlineInputBorder(),
              ),
              value: _designation,
              items: ['Admin', 'Manager', 'Employee']
                  .map((label) => DropdownMenuItem(
                        child: Text(label,style: TextStyle(fontSize: 7)),
                        value: label,
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _designation = value;
                });
              },
              validator: (value) => value == null ? 'Please select a designation' : null,
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
                        child: Text(label,style: TextStyle(fontSize: 7)),
                        value: label,
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _gender = value;
                });
              },
              validator: (value) => value == null ? 'Please select a gender' : null,
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
                        child: Text(label,style: TextStyle(fontSize: 7)),
                        value: label,
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _maritalStatus = value;
                });
              },
              validator: (value) => value == null ? 'Please select a marital status' : null,
            ),
            SizedBox(height: 16),
             ElevatedButton(
                onPressed: _signup,
                child: Text('Signup'),
              ),
              
            ],
          ),
           ),
        ),
      ),
    );
  }
}
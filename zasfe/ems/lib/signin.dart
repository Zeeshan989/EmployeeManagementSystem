
import 'dart:convert';
import 'package:ems/euserpage.dart';
import 'package:ems/muserpage.dart';
import 'package:ems/userinfo.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ems/globals.dart' as globals;
class SigninPage extends StatefulWidget {
  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signin() async {
    print('Inside login');
    final url = Uri.parse('http://192.168.207.41:8000/api/v1/users/loginuser');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
    );
    var deres = jsonDecode(response.body) as Map<String, dynamic>;
    if(response.statusCode==200 || response.statusCode==201){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 5,
          backgroundColor: Colors.green,
          content: Text(deres['message']),
          duration: Duration(seconds: 5),
        ),
      );
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 5,
          backgroundColor: Color.fromARGB(255, 160, 10, 10),
          content: Text(deres['message']),
          duration: Duration(seconds: 5),
        ),
      );
    }

    if(response.statusCode==200 || response.statusCode==201){
      print(deres['role']);
      globals.globalaccessToken=deres["accessToken"];
      if(deres['role']=='Admin'){
       Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserInfoPage()),
      );
      }
      else if(deres['role']=='Employee'){
        print('EMPLOYEEE');
        Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EuserInfoPage()),
      );

      }
      else if(deres['role']=='Manager'){
        print('MANAGER');
        Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MuserInfoPage()),
      );

      }
    }
  }
    


@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signin')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signin,
                child: Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


 int checkedmilestones=0;
    for(int i=0;i<milestones.length;i++){
      if(milestones[i]['completed']==true){
        checkedmilestones=checkedmilestones+1;
      }
    }
    var percentage=(checkedmilestones/milestones.length)*100;
    print('Milestones:${milestones}');
    print('Comments:${_commentsController.text}');
    print('Percentage of work done ${percentage.round()}');
     var url = Uri.parse('http://192.168.10.7:8000/api/v1/users/updatetask');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Milestones':milestones,
        'Comments':_commentsController.text,
        'Percentage':percentage.round(), // Ensure you pass the correct identifier
      }),
    );
   
   if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Changes saved successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save changes.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
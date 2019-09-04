import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:second_flutter/models/Note.dart';
import 'package:second_flutter/utils/database_helper.dart';

class NoteDetails extends StatefulWidget{
  String appBarTitle;
  final Note note;
  NoteDetails(this.note,this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailsState(this.note,this.appBarTitle);
  }

}

class NoteDetailsState extends State<NoteDetails>{
  String appBarTitle;
  Note note;
  NoteDetailsState(this.note,this.appBarTitle);
  
  DatabaseHelper helper = DatabaseHelper();

  static var _priorities = ['High','Low'];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    
    titleController.text = note.title;
    descriptionController.text = note.description;
    
    return Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle),
        ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.only(top:15.0, right: 10.0, left: 10.0),
          child: ListView(
            children: <Widget>[
              ListTile(
                title: DropdownButton(
                  items: _priorities.map((String item){
                    return DropdownMenuItem<String> (
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  style: textStyle,
                  value: getPriority(note.priority),
                  onChanged: (value){
                    setState(() {
                      updatePriorityInt(value);
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
                child: TextFormField(
                  controller: titleController,
                  style: textStyle,
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Please enter title';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)
                    )
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
                child: TextFormField(
                  controller: descriptionController,
                  style: textStyle,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0)
                    )
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(top: 15.0,bottom: 15.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text('Save',textScaleFactor: 1.5,),
                        onPressed: (){
                          setState(() {
                            if (_formKey.currentState.validate()) {
                              _save();
                            }
                          });
                        },
                      ),
                    ),
                    Container(width: 5.0,),
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColorDark,
                        textColor: Theme.of(context).primaryColorLight,
                        child: Text('Delete',textScaleFactor: 1.5,),
                        onPressed: (){
                          setState(() {
                            _delete();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  
  void updatePriorityInt(String value){
    switch(value){
      case 'High':
        note.priority = 1;
        break;
      case 'Low':
        note.priority = 2;
        break;
    }
  }
  
  String getPriority(int value){
    if(value ==1 ){
      return _priorities[0];
    }else{
      return _priorities[1];
    }
  }

  void updateTitle(){
    note.title = titleController.text;
  }
  void updateDescription(){
    note.description = descriptionController.text;
  }
  void _save() async{
    updateDescription();
    updateTitle();
    note.date = DateFormat.yMMMd().format(DateTime.now());
    int res;
    moveToLastScreen();

    if(note.id != null){
      res = await helper.updateNOtes(note);
    }else{
      res = await helper.insertNote(note);
    }

    if(res != 0){
      _showAlert("Status","Note Saved Successfully");
    }else{

      _showAlert("Status","Something went wrong");
    }
  }

  void _showAlert(String title, String content) {
//    Widget okButton = FlatButton(
//      child: Text("OK"),
//      onPressed: () {
//        debugPrint("click");
////        Navigator.pop(context);
////        Navigator.pop(context, true); // dialog returns true
////        Navigator.of(context).pop();
//      },
//    );
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
//        okButton,
      ],
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }

  void moveToLastScreen() {
    Navigator.pop(context,true);
  }

  void _delete() async{
    if(note.id == null){
      _showAlert("Status", "No note was deleted");
      return;
    }
    moveToLastScreen();

    int res = await helper.deleteNote(note.id);
    if(res != 0){
      _showAlert("Status", "Note Deleted Successfully");
    }else{
      _showAlert("Status", "Error Occured while deleting note");
    }
  }
}
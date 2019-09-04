import 'package:flutter/material.dart';
import 'package:second_flutter/models/Note.dart';
import 'package:second_flutter/utils/database_helper.dart';
import 'package:second_flutter/views/NoteDetails.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if(noteList == null){
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
      body: getNotes(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetails(Note('','', 2),"Add Note");
        },
        tooltip: "Add Note",
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getNotes() {
    TextStyle textStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(this.noteList[position].priority),
              child: getPriorityIcon(this.noteList[position].priority),
            ),
            title: Text(this.noteList[position].title, style: textStyle),
            subtitle: Text(
                this.noteList[position].date
            ),
            trailing: GestureDetector(
              child: Icon(
                Icons.delete,
                color: Colors.grey,
              ),
              onTap: (){
                _delete(context, this.noteList[position]);
              },
            ),
            onTap: () {
              navigateToDetails(this.noteList[position],"Edit Note");
            },
          ),
        );
      },
    );
  }

  void navigateToDetails(Note note,String title) async{
    bool res = await Navigator.push(context, MaterialPageRoute(builder: (context){
      return NoteDetails(note,title);
    }));
    if(res){
      updateListView();
    }
  }

  Color getPriorityColor(int priority){
    switch(priority){
      case 1:
        return Colors.red;
      default:
        return Colors.yellow;
    }
  }

  Icon getPriorityIcon(int priority){
    switch(priority){
      case 1:
        return Icon(Icons.play_arrow);
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }
  Future _delete(BuildContext context,Note note) async {
    int result = await databaseHelper.deleteNote(note.id);

    if(result != 0){
      _showSnakeBar(context,'Note Deleted Successfully');
      updateListView();
    }

  }

  void _showSnakeBar(BuildContext context, String message) {
    final snackbar = SnackBar(content: Text(message),);
    Scaffold.of(context).showSnackBar(snackbar);
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database){
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList){
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}

import 'package:flutter/material.dart';
import 'package:second_flutter/views/NoteList.dart';

void main() =>runApp(MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Note Keeper',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
        primarySwatch: Colors.deepPurple
    ),
    home: NoteList(),
    );
  }
}

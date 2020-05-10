import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.white,
    accentColor: Colors.pinkAccent,
  ),
  home: MyApp(),
),);

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String input = "";

  createTask() {
    DocumentReference documentReference = Firestore.instance.collection("TODO").document(input);

    Map<String, String> task = {"title": input};
    documentReference.setData(task).whenComplete(() {
      print("$input created");
    });
  }

  deleteTask(item) {
    DocumentReference documentReference = Firestore.instance.collection("TODO").document(item);

    documentReference.delete().whenComplete(() {
      print("$item deleted");
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO',
        style: TextStyle(
          fontSize: 40.0,
          fontWeight: FontWeight.bold,
        ),),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (BuildContext context){
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              title: Text("Add Task"),
              content: TextField(
                onChanged: (String value){
                  input = value;
                },
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    createTask();
                    Navigator.of(context).pop();
                  },
                  child: Text("Add"),
                ),
              ],
            );
          });
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: StreamBuilder(stream: Firestore.instance.collection("TODO").snapshots(),
        builder: (context, snapshots){
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshots.data.documents.length,
            itemBuilder: (context, index){
              DocumentSnapshot documentSnapshot = snapshots.data.documents[index];
              return Dismissible(
                onDismissed: (direction){
                  deleteTask(documentSnapshot["title"]);
                },
                key: Key(documentSnapshot["title"]),
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    title: Text(documentSnapshot["title"]),
                    trailing: IconButton(icon: Icon(Icons.delete, color: Colors.red,),
                      onPressed: (){
                      deleteTask(documentSnapshot["title"]);
                      },
                    ),
                  ),
                ),);
            });
        },
      ),
    );
  }
}



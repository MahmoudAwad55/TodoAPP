import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,

    home: MyApp(),
  ));
}

//snippet stfl for vscode
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String input = "";
  String description = "";

  createTodos() {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyTodos").doc(input);

    //Map
    Map<String, String> todos = {"todoTitle": input,"todoDesc": description};
    documentReference.set(todos).whenComplete(() {
      print("$input created");
    });
  }

  deleteTodos(item) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection("MyTodos").doc(item);

    documentReference.delete().whenComplete(() {
      print("$item deleted");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("myTodos"), backgroundColor: Colors.deepPurple),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: Text("Add TodoList"),
                    content: Container(
                      width: 300,
                      height: 200,
                      child: Column(
                        children: [
                          TextField(
                              maxLines: 1,
                              onChanged: (String value) {
                                input = value;
                              },
                              decoration: InputDecoration(
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: "Title",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ))),
                          SizedBox(height: 20),
                          TextField(
                              maxLines:4 ,
                              onChanged: (String value) {
                                description = value;
                              },
                              decoration: InputDecoration(
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: "Description",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )))
                        ],
                      ),

                    ),

                    actions: <Widget>[
                      ElevatedButton(
                          onPressed: () {
                            createTodos();
                            Navigator.of(context).pop(); // closes the dialog
                          },
                          child: Text("Add")),
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('cancel'))
                    ]
                );
              });
        },
        label: Text('Add Todo '),
        icon: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("MyTodos").snapshots(),
          builder: (context, snapshots) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshots.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot documentSnapshot =
                      snapshots.data!.docs[index];
                  return Dismissible(
                      onDismissed: (direction) {
                        deleteTodos(documentSnapshot["todoTitle"]);
                      },
                      key: Key(documentSnapshot["todoTitle"]),
                      child: Card(
                        elevation: 4,
                        margin: EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          title: Text(documentSnapshot["todoTitle"]),
                          subtitle: Text((documentSnapshot != null)
                              ? ((documentSnapshot["todoDesc"] != null)
                              ? documentSnapshot["todoDesc"]
                              : "")
                              : ""),
                          trailing: IconButton(
                              icon: Icon(Icons.delete_forever, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  deleteTodos(documentSnapshot["todoTitle"]);
                                });
                              }),
                        ),
                      ));
                });
          }),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/string_apis.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  String task = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Real Time DataBase"),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              /// this .orderBy('time') is optional you use in case you need
              /// this is stream  fireStore.collection('tasks').snapshots() of snapshot
              stream: fireStore.collection('tasks').orderBy('time').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Text("Loading")
                  );
                }
                if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = snapshot.data!.docs[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: Colors.deepPurple.shade50,
                            elevation: 0,
                            child: ListTile(
                              onTap: () => showdailog(true, document),
                              leading: Container(
                                  height: 50,
                                  width:  50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.deepPurple.shade200.withOpacity(.5),
                                  ),
                                  child: Text("${document["task"][0].toString().toUpperCase()}",
                                    style: TextStyle(fontSize: 24,color: Colors.white),),
                                  alignment: Alignment.center),
                              title: Text(document["task"]),
                              subtitle: Text("${document["time"].toString().toTimeParse()}"),
                              trailing: IconButton(onPressed: (){
                                ///delete Function
                                fireStore.collection("tasks").doc(document.id).delete();
                              }, icon: const Icon(Icons.delete)),
                            ),
                          ),
                        );
                      }
                    ),
                  );
                }
                if (snapshot.hasError){
                  return const Center(child: Text("Something went wrong"));
                }
                  return  Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
          showdailog(false, null),
        child: const Icon(Icons.add_box_outlined),
      ),
    );
  }

  void showdailog(bool isUpdate, DocumentSnapshot? document) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    Map<String,dynamic> e = document!.data() as Map<String,dynamic>;
    print(e["task"].toString()+ 'aaaa');
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: isUpdate?Text("Edit todo") : Text("Add todo"),
              content: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: TextFormField(
                  initialValue: isUpdate
                      ? e["task"].toString()
                      : "",
                  autofocus: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Task"),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return "Can not bre Empty";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) => task = value,
                ),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      if(isUpdate){
                        fireStore.collection("tasks").doc(document!.id).update({
                          "task":task,
                          "time": DateTime.now().toIso8601String(),
                        });
                      }
                      else{fireStore.collection("tasks").add(
                          {"task": task,
                            "time": DateTime.now().toIso8601String(),
                          }
                      );}
                      Navigator.of(context).pop();
                    },
                    child: const Text("add"))
              ],
            ));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
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
                        return ListTile(
                          onTap: () => showdailog(true, document),
                          leading: Text("${index+1}"),
                          title: Text(document["task"]),
                          subtitle: Text(document["time"].toString()),
                          trailing: IconButton(onPressed: (){
                            ///delete Function
                            fireStore.collection("tasks").doc(document.id).delete();
                          }, icon: const Icon(Icons.delete)),
                        );
                      }
                    ),
                  );
                }
                if (snapshot.hasData){
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
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Add todo"),
              content: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: TextFormField(
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
                          "time": DateTime.now(),
                        });
                      }
                      else{fireStore.collection("tasks").add(
                          {"task": task,
                            "time": DateTime.now(),
                          }
                      );}
                      Navigator.of(context).pop();
                    },
                    child: const Text("add"))
              ],
            ));
  }
}

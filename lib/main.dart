import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MyHomePage(title: 'Not WhatsApp'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final firestore = FirebaseFirestore.instance;
  TextEditingController massageController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  var messageCounter;



  sendMassage(String? massage, String? user) async {
    await firestore
        .collection("data")
        .doc("${DateTime.now()}")
        .set({'massage': massage, 'time': Timestamp.now(), "User": user});
  }

  deleteMassageForAll(String? id) async {
    await firestore.collection("data").doc(id).delete();
  }

  updateMassage(String? id, String? data) async {
    await firestore
        .collection("data")
        .doc(id)
        .update({'massage': data, 'time': Timestamp.now()});
  }

  handleTime(Timestamp time) {
    DateTime handleTime = time.toDate();
    if (handleTime.hour > 12) {
      return "${handleTime.hour - 12} : ${handleTime.minute}";
    } else {
      return "${handleTime.hour} : ${handleTime.minute}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
              stream: firestore.collection("data").snapshots(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          messageCounter=index;
                          print(" massage Counter $messageCounter ${messageCounter.runtimeType} ");
                          return Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Align(
                              alignment:
                                  snapshot.data!.docs[index]['User'] == 'user2'
                                      ? Alignment.centerLeft
                                      : Alignment.centerRight,
                              child: Container(
                                width: 280,
                                decoration: BoxDecoration(
                                    color: snapshot.data!.docs[index]['User'] ==
                                            'user2'
                                        ? Colors.black12
                                        : Colors.teal,
                                    borderRadius: BorderRadius.circular(25)),
                                child: InkWell(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text(
                                              snapshot.data!.docs[index]
                                                  ['massage'],
                                              style:
                                                  const TextStyle(fontSize: 20),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0,0,1,0),
                                          child: Text(
                                            handleTime(snapshot
                                                .data!.docs[index]['time']),
                                            style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: snapshot.data!.docs[index]['User'] ==
                                              'user2' ? Text(
                                            snapshot.data!.docs[index]['User'],
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.black),
                                          ):null,
                                        )
                                      ],
                                    ),
                                    onDoubleTap: () {
                                      deleteMassageForAll(
                                          snapshot.data!.docs[index].id);
                                    },
                                    onLongPress: () {
                                      if (_key.currentState!.validate()) {
                                        updateMassage(
                                            snapshot.data!.docs[index].id,
                                            massageController.text);
                                        massageController.clear();
                                      }
                                    }),
                              ),
                            ),
                          );
                        }),
                  );
                } else if (snapshot.hasError) {
                  return const Center(child: Text("errorrrrr"));
                } else {
                  return const CircularProgressIndicator();
                }
              }),
          Form(
            key: _key,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return "";
                  }
                  return null;
                },
                controller: massageController,
                decoration: const InputDecoration(
                  hintText: "Massage",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_key.currentState!.validate()) {
                      sendMassage(massageController.text, "user");
                      massageController.clear();
                    }
                  },
                  child: const Icon(
                    Icons.chevron_left,
                  ),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<CircleBorder>(
                          const CircleBorder(
                              side: BorderSide(color: Colors.teal)))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_key.currentState!.validate()) {
                      sendMassage(massageController.text, "user2");
                      massageController.clear();
                    }
                  },
                  child: const Icon(
                    Icons.chevron_right,
                    color: Colors.deepOrangeAccent,
                  ),
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<CircleBorder>(
                          const CircleBorder(
                              side: BorderSide(color: Colors.teal)))),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

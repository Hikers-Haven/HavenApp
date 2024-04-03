import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  int selectedTab = 1;
  String selectedText = "First Tab";
  List<Object ?> dataList = []; // List to hold fetched data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fox Valley Cyclists"),
        backgroundColor: Colors.lightGreen[300],
      ),
      backgroundColor: Colors.green[200],
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.purple[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton(
                    onPressed: () async {
                      final ref = FirebaseDatabase.instance.ref();
                      for(int i = 0;i <= 8;i++){
                        final snapshot = await ref.child('POI/WS$i').get();
                        if (snapshot.exists) {
                          print(snapshot.value);
                          dataList.add(snapshot.value);
                        } else {
                          print('No data available.');
                        }
                        setState(() {
                          selectedTab = 1;
                          selectedText = snapshot.value.toString();
                        });
                        for(int i = 0;i < dataList.length;i++){
                          dataList.removeAt(i);
                        }
                      }
                    },
                    child: Text(
                      "Water Stations",
                      style: TextStyle(
                          fontWeight: selectedTab == 1
                              ? FontWeight.bold
                              : FontWeight.normal),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final ref = FirebaseDatabase.instance.ref();
                      for(int i = 0;i <= 5;i++) {
                        final snapshot = await ref.child('POI/BR$i').get();
                        if (snapshot.exists) {
                          print(snapshot.value);
                          dataList.add(snapshot.value);
                        } else {
                          print('No data available.');
                        }
                        setState(() {
                          selectedTab = 2;
                          selectedText = snapshot.value.toString();
                        });
                        for(int i = 0;i < dataList.length;i++){
                          dataList.removeAt(i);
                        }
                      }
                    },
                    child: Text(
                      "Repair Stations",
                      style: TextStyle(
                          fontWeight: selectedTab == 2
                              ? FontWeight.bold
                              : FontWeight.normal),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedTab = 3;
                        selectedText = "Third Tab";
                      });
                    },
                    child: Text(
                      "More",
                      style: TextStyle(
                          fontWeight: selectedTab == 3
                              ? FontWeight.bold
                              : FontWeight.normal),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.6,
              child: ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(dataList[index].toString()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
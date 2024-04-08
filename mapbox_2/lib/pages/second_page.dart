import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  _SecondPageState createState() => _SecondPageState();
}

class MyData {
  final dynamic _pid;
  final dynamic _lat;
  final dynamic _lng;

  MyData(this._pid, this._lat, this._lng);

  @override
  String toString() {
    // Custom implementation of toString()
    return 'Location: $_pid  Latitude: $_lat  Longitude:  $_lng';
  }
}

class _SecondPageState extends State<SecondPage> {
  int selectedTab = 1;
  String selectedText = "First Tab";
  List<Object?> dataList = []; // List to hold fetched data

  Future<void> fetchData(String category) async {
    final ref = FirebaseDatabase.instance.ref();
    dataList.clear(); // Clear the list before fetching new data

    String poiType = category == "Water Stations" ? "WS" : "BR";

    for (int i = 1; i <= (category == "Water Stations" ? 8 : 5); i++) {
      final snapshot = await ref.child('POI/$poiType$i').get();
      if (snapshot.exists) {
        // Check if snapshot value is not null
        if (snapshot.value != null) {
          Map<dynamic, dynamic> map = snapshot.value! as Map<dynamic, dynamic>;
          var pid = map["pid"];
          var lat = map["lat"];
          var lng = map["lng"];
          // Check if 'lat' and 'lng' properties exist and are not null
          if (lat != null && lng != null) {
            // Create MyData instance from the snapshot data
            MyData data = MyData(
              pid,
              lat,
              lng,
            );
            dataList.add(data);
          }
        } else {
          print('No data available for $category $i.');
        }
      }
    }
  }


  String getTitleText() {
    switch (selectedTab) {
      case 1:
        return "Water Station";
      case 2:
        return "Repair Station";
      case 3:
        return "More";
      default:
        return "Default Title";
    }
  }

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
                      await fetchData("Water Stations");
                      setState(() {
                        selectedTab = 1;
                      });
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
                      await fetchData("Repair Stations");
                      setState(() {
                        selectedTab = 2;
                      });
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
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                child: ListView.builder(
                  itemCount: dataList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        "${getTitleText()} ${index + 1}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        dataList[index].toString(),
                        style: TextStyle(fontSize: 16),
                      ),
                      tileColor: Colors.grey[200],
                      contentPadding: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

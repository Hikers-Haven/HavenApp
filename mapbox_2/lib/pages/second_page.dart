import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  dynamic get pid => _pid; // Getter for pid
  dynamic get lat => _lat; // Getter for lat
  dynamic get lng => _lng; // Getter for lng


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

  @override
  void initState() {
    super.initState();
    fetchData("Water Stations"); // Fetch data for the first category
  }

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
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
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
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (context, index) {
                  final MyData data = dataList[index] as MyData;
                  final String pid = data.pid;
                  final String lat = data._lat.toString(); // Convert to string
                  final String lng = data._lng.toString(); // Convert to string
                  final String textAreaId = '${getTitleText()}_$index'; // Unique textAreaId

                  return Column(
                    children: [
                      ListTile(
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
                      ),
                      VoteWidget(textAreaId: textAreaId), // Pass unique textAreaId
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, {'latitude': lat, 'longitude': lng});
                        },
                        child: Text('Show Location'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Points Of Intrest"),
          content: Text(
            "This page displays information about water stations and repair stations for cyclists."
                "You can select a category from the top buttons to view the corresponding stations on the map."
                "Each station is accompanied by an upvote/downvote feature to provide feedback on its quality.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Got It"),
            ),
          ],
        );
      },
    );
  }
}

Future<bool> hasUserVoted(String userId, String textAreaId) async {
  final snapshot = await FirebaseDatabase.instance
      .ref()
      .child('votes')
      .child(textAreaId)
      .child('voters')
      .child(userId)
      .once();
  return snapshot.snapshot.value != null;
}

Future<void> recordUserVote(String userId, String textAreaId) async {
  await FirebaseDatabase.instance
      .ref()
      .child('votes')
      .child(textAreaId)
      .child('voters')
      .child(userId)
      .set(true);
}

class VoteWidget extends StatefulWidget {
  final String textAreaId;

  const VoteWidget({required this.textAreaId});

  @override
  _VoteWidgetState createState() => _VoteWidgetState();
}

class _VoteWidgetState extends State<VoteWidget> {
  late DatabaseReference _votesRef;
  int _upvoteCount = 0;
  int _downvoteCount = 0;

  @override
  void initState() {
    super.initState();
    _votesRef = FirebaseDatabase.instance.ref().child('votes').child(widget.textAreaId);
    _fetchVoteCounts();
  }

  Future<void> _fetchVoteCounts() async {
    final upvoteSnapshot = await _votesRef.child('upvote').get();
    final downvoteSnapshot = await _votesRef.child('downvote').get();

    if (upvoteSnapshot.exists) {
      setState(() {
        _upvoteCount = int.parse(upvoteSnapshot.value.toString());
      });
    }

    if (downvoteSnapshot.exists) {
      setState(() {
        _downvoteCount = int.parse(downvoteSnapshot.value.toString());
      });
    }
  }


  Future<void> _upvote() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      bool hasVoted = await hasUserVoted(userId, widget.textAreaId); // Use widget.textAreaId
      if (!hasVoted) {
        await recordUserVote(userId, widget.textAreaId); // Use widget.textAreaId
        final Map<String, dynamic> updateData = {
          'upvote': ServerValue.increment(1)
        };
        await _votesRef.update(updateData);
        setState(() {
          _upvoteCount++;
        });
      } else {
        // User has already voted for this area
        // Handle accordingly (e.g., show a message)
      }
    }
  }

  Future<void> _downvote() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
      bool hasVoted = await hasUserVoted(userId, widget.textAreaId); // Use widget.textAreaId
      if (!hasVoted) {
        await recordUserVote(userId, widget.textAreaId); // Use widget.textAreaId
        final Map<String, dynamic> updateData = {
          'downvote': ServerValue.increment(1)
        };
        await _votesRef.update(updateData);
        setState(() {
          _downvoteCount++;
        });
      } else {
        // User has already voted for this area
        // Handle accordingly (e.g., show a message)
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_upward),
              onPressed: _upvote,
            ),
            Text('$_upvoteCount'),
            IconButton(
              icon: Icon(Icons.arrow_downward),
              onPressed: _downvote,
            ),
            Text('$_downvoteCount'),
          ],
        ),
      ],
    );
  }
}

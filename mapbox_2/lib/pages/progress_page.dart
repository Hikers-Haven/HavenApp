import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mapbox_2/customAppBar.dart';

class FourthPage extends StatefulWidget {
  @override
  _FourthPageState createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
  List<ChartData> chartData = [];

  @override
  void initState() {
    super.initState();
    _fetchBikingActivity();
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Personal Progress"),
          content: Text(
            "This page displays biking activity over the past week."
                "It shows the distance traveled in each biking session."
                "You can use this information to track your progress over time.",
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
  Future<void> _fetchBikingActivity() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('biking_sessions')
          .orderBy('timestamp', descending: true)
          .limit(7)
          .get();

      List<ChartData> data = [];
      int index = 1;
      snapshot.docs.forEach((doc) {
        // Process each biking session document
        data.add(ChartData(index, doc['distance_traveled']));
        index++;
      });

      setState(() {
        chartData = data.reversed.toList(); // Reverse the list for correct order
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    final List<ChartData> chartData = [
      ChartData(1, 7.2),
      ChartData(2, 6.7),
      ChartData(3, 9.8),
      ChartData(4, 8.8),
      ChartData(5, 9.1),
      ChartData(6, 7.3),
      ChartData(7, 0.8),
    ];

    final List<Color> color = <Color>[];
    color.add(Colors.cyanAccent[700]!);

    color.add(Colors.greenAccent[700]!);


    final List<double> stops = <double>[];
    stops.add(0.1);
    stops.add(0.9);

    final LinearGradient gradientColors = LinearGradient(
        colors: color,
        stops: stops,
        transform: const GradientRotation(90 * (3.14 / 180)));

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
        backgroundColor: Colors.green,
        body: Center(
            child: ListView(
              children: <Widget>[
                Container(
                  width: 290,
                  height: 290,
                  margin: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      color: Colors.green[600],
                      border: Border.all(
                          width: 6,
                          color: Colors.green[600]!
                      ),
                      borderRadius: BorderRadius.circular(12)
                  ),
                  child: SfCartesianChart(
                    series: <CartesianSeries>[
                      SplineAreaSeries<ChartData, int>(
                        dataSource: chartData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        splineType: SplineType.cardinal,
                        gradient: gradientColors,
                      )
                    ],
                  ),
                ),
              ],
            )
        )
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);

  final int x;
  final double? y;
}
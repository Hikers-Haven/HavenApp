import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';

class FourthPage extends StatefulWidget {
  @override
  _FourthPageState createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> with SingleTickerProviderStateMixin {
  CustomBoxDecoration customBox = CustomBoxDecoration();
  List<ChartData> chartData = [];
  double avg_miles = 0.0;
  double avg_speed = 0.0;
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _fetchBikingActivity();
    _initAnimation();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0, end: avg_speed).animate(_animationController!)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(covariant FourthPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (avg_speed != _animation!.value) {
      _animation = Tween<double>(begin: _animation!.value, end: avg_speed)
          .animate(_animationController!)
        ..addListener(() {
          setState(() {});
        });
      _animationController!.reset();
      _animationController!.forward();
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
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
      DateTime now = DateTime.now();
      DateTime sevenDaysAgo = now.subtract(Duration(days: 6)); // Including today

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('biking_sessions')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .orderBy('timestamp', descending: true)
          .get();

      Map<String, double> dailyDistances = {};
      Map<String, int> counts = {};

      for (int i = 0; i < 7; i++) {
        DateTime day = sevenDaysAgo.add(Duration(days: i));
        String formattedDate = DateFormat('MM/dd').format(day);
        dailyDistances[formattedDate] = 0.0;
        counts[formattedDate] = 0;
      }

      for (var doc in snapshot.docs) {
        Timestamp t = doc['timestamp'];
        DateTime date = t.toDate();
        String formattedDate = DateFormat('MM/dd').format(date);
        if (dailyDistances.containsKey(formattedDate)) {
          // Explicitly cast the data to Map<String, dynamic>
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          double distance = 0.0; // Initialize distance
          if (data.containsKey('distance_traveled') && data['distance_traveled'] != null) {
            distance = data['distance_traveled'].toDouble();
          }
          if (dailyDistances.containsKey(formattedDate)) {
            if (dailyDistances[formattedDate] == null) {
              dailyDistances[formattedDate] = 0.0; // Initialize to zero if null
            }
            dailyDistances[formattedDate] = dailyDistances[formattedDate]! + distance; // Safely add distance
          }

          if (counts.containsKey(formattedDate)) {
            if (counts[formattedDate] == null) {
              counts[formattedDate] = 0; // Initialize to zero if null
            }
            counts[formattedDate] = counts[formattedDate]! + 1; // Safely increment
          }

        }
      }

      double totalDistance = 0.0;
      int daysWithData = 0;
      for (double distance in dailyDistances.values) {
        totalDistance += distance;
      }
      for (int count in counts.values) {
        if (count > 0) {
          daysWithData++;
        }
      }

      List<ChartData> localChartData = [];
      for (var entry in dailyDistances.entries) {
        localChartData.add(ChartData(entry.key, entry.value, Colors.deepOrange));
      }

      setState(() {
        chartData = localChartData;

        // Using if-else for avg_miles calculation
        if (daysWithData > 0) {
          avg_miles = totalDistance / daysWithData;
        } else {
          avg_miles = 0.0;
        }

        double totalSpeed = 0.0;
        int countSpeeds = 0;
        for (var doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('average_speed') && data['average_speed'] != null) {
            totalSpeed += data['average_speed'].toDouble();
            countSpeeds++;
          }
        }

        // Using if-else for avg_speed calculation
        if (countSpeeds > 0) {
          avg_speed = totalSpeed / countSpeeds;
        } else {
          avg_speed = 0.0;
        }
      });

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
        backgroundColor: Colors.green,
        body: Center(
            child: ListView(
              children: <Widget>[
                Container(
                  width: 290,
                  height: 290,
                  margin: const EdgeInsets.all(10.0),
                  decoration: customBox.boxWidgetDecoration(),
                  child: SfCartesianChart(
                    primaryXAxis: const CategoryAxis(
                      title: AxisTitle(
                          text: 'Date',
                          textStyle: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    primaryYAxis: const NumericAxis(
                      title: AxisTitle(
                          text: 'Miles Biked',
                          textStyle: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold)),
                    ),
                    series: <CartesianSeries>[
                      ColumnSeries<ChartData, String>(
                        dataSource: chartData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        pointColorMapper: (ChartData data, _) => data.color,
                      )
                    ],
                  ),
                ),
                Container(
                  width: 290,
                  height: 70,
                  margin: const EdgeInsets.all(10.0),
                  decoration: customBox.boxWidgetDecoration(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                        children: <InlineSpan>[
                          const TextSpan(text: 'Your average miles in the last 7 days was '),
                          TextSpan(
                            text: '${avg_miles.toStringAsFixed(2)} ',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                          ),
                          const WidgetSpan(
                            child: Icon(Icons.directions_bike, size: 18, color: Colors.deepOrange),
                            alignment: PlaceholderAlignment.middle,
                          ),
                          const TextSpan(text: ' and average speed was '),
                          TextSpan(
                            text: '${avg_speed.toStringAsFixed(0)} MPH ',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                          ),
                          const WidgetSpan(
                            child: Icon(Icons.speed, size: 18, color: Colors.deepOrange),
                            alignment: PlaceholderAlignment.middle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 290,
                  height: 290,
                  margin: const EdgeInsets.all(10.0),
                  decoration: customBox.boxWidgetDecoration(),
                  child: SfRadialGauge(
                    enableLoadingAnimation: true,
                    animationDuration: 4500,
                    title: const GaugeTitle(
                        text: 'Average Speed (MPH)',
                        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: 0,
                        maximum: 30,
                        ranges: [
                          GaugeRange(
                            startValue: 0,
                            endValue: avg_speed,
                            color: Colors.deepOrange.withOpacity(1.0),
                            startWidth: 10,
                            endWidth: 10,
                          ),
                        ],
                        pointers: [
                          NeedlePointer(
                            value: avg_speed,
                            needleStartWidth: 1,
                            needleEndWidth: 5,
                            knobStyle: const KnobStyle(
                                knobRadius: 10,
                                sizeUnit: GaugeSizeUnit.logicalPixel,
                                color: Colors.deepOrange),
                          )
                        ],
                        annotations: [
                          GaugeAnnotation(
                            angle: 90,
                            positionFactor: 0.5,
                            widget: Text("${avg_speed.toStringAsFixed(0)} MPH",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 20)),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            )
        )
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.color);
  final String x;
  final double y;
  final Color? color;
}

// class CustomBoxDecoration {
//   BoxDecoration boxWidgetDecoration() {
//     return BoxDecoration(
//         color: Colors.grey[100],
//         border: Border.all(width: 6, color: Colors.grey[100]!),
//         borderRadius: BorderRadius.circular(12));
//   }
// }

class CustomBoxDecoration {
  BoxDecoration boxWidgetDecoration() {
    return BoxDecoration(
      color: const Color(0xFFA881D5),  // A light purple color
      // This will be overridden by gradient if gradient is used
      border: Border.all(width: 6, color: Colors.brown),
      borderRadius: BorderRadius.circular(12),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          // Color(0xFF84D581),  // A fresh greenish color
          // Color(0xFFD5D281),
          // Color(0xFFA881D5),
          // Color(0xFFD58184)
          Color(0xFFAED581),
          Color(0xFFAED581)
        ],
      ),
    );
  }
}


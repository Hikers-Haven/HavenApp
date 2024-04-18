import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mapbox_2/customAppBar.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';


class FourthPage extends StatefulWidget {
  @override
  _FourthPageState createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
  CustomBoxDecoration customBox = CustomBoxDecoration();
  List<ChartData> chartData = [];
  double avg_miles = 0.0;
  double avg_speed = 0.0;
  int weekday_num = 0;
  String tStamp = "";

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
          .get();

      DateTime d = DateTime.now();
      int currentDay = GetWeekDayAsInteger().convertTimeStamp(d);
      int checkCurrentDay = GetWeekDayAsInteger().convertTimeStamp(d);

      List<ChartData> data = [];
      int numOfSpeedDocs = 0;
      double avg_m = 0.0;
      double avg_s = 0.0;
      int weekday_n = 7;
      String tS = "";
      bool stop = true;
      double average = 0.0;
      int getRemainingDays = 0;
      for (var doc in snapshot.docs) {
        // Grab the time stamp, break it down until it is just
        // a usable integer data value
        Timestamp t = doc['timestamp'];
        DateTime timeStampDate = t.toDate();
        tS = GetWeekDayAsInteger().convertTimeStamp(timeStampDate).toString();
        int currentTimeStamp = GetWeekDayAsInteger().convertTimeStamp(timeStampDate);

        if (stop && currentTimeStamp != checkCurrentDay){
          getRemainingDays = checkCurrentDay - currentTimeStamp;
          for (int i = 0; i < getRemainingDays; i++){
            data.add(ChartData(checkCurrentDay, 0.0, Colors.deepOrange));
            checkCurrentDay -= 1;
          }
          weekday_n = weekday_n - (currentDay - checkCurrentDay);
          stop = false;
        }

        // store the accumulated data into a new ChartData element
        if(currentTimeStamp != checkCurrentDay){
          data.add(ChartData(checkCurrentDay, avg_m, Colors.deepOrange));
          checkCurrentDay -= 1;
          avg_m = 0.0;
          weekday_n -= 1;

          // leave the loop when you reach the 7th day from today
          if (weekday_n == 0){
            break;
          }
        }


        // grab average speed from the past 7 sessions
        // and get the total average from all avg speeds.
        double getSpeed = doc['average_speed'];
        String conSpeed = getSpeed.toStringAsFixed(1);
        double avgSpeed = double.parse(conSpeed);
        avg_s += avgSpeed;

        if (currentTimeStamp == checkCurrentDay) { // 13th == 13th
          // grab distance traveled, make double fixed to
          // 2 decimal places and then parse back to double
          double getDist = doc['distance_traveled'];
          String conDist = getDist.toStringAsFixed(2);
          double dist = double.parse(conDist);
          avg_m += dist;
        }
      }

      average = avg_s / 7.0;
      String convertAverage = average.toStringAsFixed(1);
      average = double.parse(convertAverage);

      setState(() {
        chartData = data.reversed.toList(); // Reverse the list for correct order
        avg_miles = avg_m; // get the average miles biked for the last 7 sessions
        avg_speed = average; // get the average spd for the last 7 sessions, get overall avg
        tStamp = tS;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: customAppBar(),
        backgroundColor: Colors.green[900],
        body: Center(
            child: ListView(
              children: <Widget>[
                Container(
                  width: 290,
                  height: 290,
                  margin: const EdgeInsets.all(10.0),
                  decoration: customBox.boxWidgetDecoration(),
                  child: SfCartesianChart(
                    primaryXAxis: const NumericAxis(
                      title: AxisTitle(
                          text: 'Miles Per Day',
                          textStyle: TextStyle(
                              fontWeight: FontWeight.bold
                          )),
                    ),
                    primaryYAxis: const NumericAxis(
                      title: AxisTitle(
                          text: 'Miles Biked',
                          textStyle: TextStyle(
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold
                          )),
                    ),
                    series: <CartesianSeries>[
                      ColumnSeries<ChartData, int>(
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
                  height: 290,
                  margin: const EdgeInsets.all(10.0),
                  decoration: customBox.boxWidgetDecoration(),
                  child: Text("Your average miles in the last 7 days was $avg_miles and day is $tStamp"),
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
                        text: 'Avg MPH per latest days',
                        textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black
                        )
                    ),
                    axes: <RadialAxis>[
                      RadialAxis(
                        pointers: <GaugePointer>[
                          NeedlePointer(
                            value: avg_speed,
                            needleStartWidth: 1,
                            needleEndWidth: 5,
                            knobStyle: const KnobStyle(
                                knobRadius: 10,
                                sizeUnit: GaugeSizeUnit.logicalPixel,
                                color: Colors.deepOrange
                            ),
                          )
                        ],
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                            angle: 90,
                            positionFactor: 0.5,
                            widget: Text("$avg_speed MPH",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrange,
                                    fontSize: 20
                                )),
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
  final int x;
  final double y;
  final Color? color;
}

class GetWeekDayAsInteger{
  GetWeekDayAsInteger();

  int convertTimeStamp(theDate){
    String convertDateToString = theDate.toString();
    convertDateToString = DateFormat.yMMMd().add_jms().format(theDate).toString();

    // grab the time stamp string and grab the current day number
    List<String> timeToList = convertDateToString.split(", ");
    String getFirstIndex = timeToList[0];
    List<String> getDay = getFirstIndex.split(" ");
    String getDayNumber = getDay[1];
    int parseDate = int.parse(getDayNumber);
    return parseDate;
  }
}

class CustomBoxDecoration {
  BoxDecoration boxWidgetDecoration(){
    return BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(
            width: 6,
            color: Colors.grey[100]!
        ),
        borderRadius: BorderRadius.circular(12)
    );
  }
}
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
  int weekday_num = 0;
  String tStamp = "";
  List<HoldSnapData> holdSData = [];
  String test = "";
  AnimationController? _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _fetchBikingActivity();
    _initAnimation();
  }

  // void _initAnimation() {
  //   _animationController = AnimationController(
  //     vsync: this,
  //     duration: Duration(seconds: 2),
  //   );
  //   _animation = Tween<double>(begin: 0, end: avg_speed).animate(_animationController!)
  //     ..addListener(() {
  //       setState(() {});
  //     });
  // }

  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    // Create the animation
    _animation = Tween<double>(begin: 0, end: avg_speed).animate(_animationController as Animation<double>);
    //tween means the range of values that the animation will go through

    // Add the listener
    _animationController?.addListener(() {
      setState(() {});
    });
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
            "This page displays biking activity over the past week. It shows the distance traveled in each biking session. You can use this information to track your progress over time.",
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

      List<HoldSnapData> holdSnapshotData = [];
      List<ChartData> data = [];
      double avg_m = 0.0;
      double avg_s = 0.0;
      String tS = "";
      double average = 0.0;
      double aver_m = 0.0;

      String testString = "";
      Timestamp theTime = snapshot.docs.first['timestamp'];
      DateTime dd = theTime.toDate();
      int cts = GetWeekDayAsInteger().convertTimeStamp(dd);
      int currentTimeStamp = 0;

      double bigolavg = 0;
      double bigoldist = 0;
      int ctr = 0;
      if(snapshot.docs.isNotEmpty){
        for (var doc in snapshot.docs) {
          Timestamp t = doc['timestamp'];
          DateTime timeStampDate = t.toDate();
          tS = GetWeekDayAsInteger().convertTimeStamp(timeStampDate).toString();
          currentTimeStamp = GetWeekDayAsInteger().convertTimeStamp(timeStampDate);

          if (currentTimeStamp != cts){
            int getday = currentTimeStamp + (cts - currentTimeStamp);
            holdSnapshotData.add(HoldSnapData(getday, avg_m, avg_s));
            cts = getday - (cts - currentTimeStamp);
            avg_m = 0.0;
            avg_s = 0.0;
          }

          if (doc['distance_traveled'] > 0.1 && doc['average_speed'] > 1.0 && doc['time_elapsed'] > 1.0){
            double getDist = doc['distance_traveled'];
            String conDist = getDist.toStringAsFixed(2);
            double dist = double.parse(conDist);
            avg_m += dist;

            double getSpeed = doc['average_speed'];
            String conSpeed = getSpeed.toStringAsFixed(1);
            double avgSpeed = double.parse(conSpeed);
            avg_s += avgSpeed;

            print("Distance: $dist");
            bigoldist += dist;
            print("Speed: $avgSpeed");
            bigolavg += avgSpeed;
            ctr += 1;

            print("Big ol dist: $bigoldist");
            print("Big ol avg: $bigolavg");
            print("Ctr: $ctr");
            print("time elapsed: ${doc['time_elapsed']}");

          }
        }

        holdSnapshotData.add(HoldSnapData(currentTimeStamp, avg_m, avg_s));

        double average_s = 0.0;
        double average_m = 0.0;
        int size = holdSnapshotData.length;

        int itr = 7;
        int x = holdSnapshotData.elementAt(0).day;
        for (int i = 0; i < itr; i++){
          if (holdSnapshotData.isNotEmpty){
            x = holdSnapshotData.elementAt(0).day;
          } else {
            x = 0;
          }

          if (checkCurrentDay != x){
            data.add(ChartData("${checkCurrentDay}th", 0.0, Colors.deepOrange));
            checkCurrentDay -= 1;
          } else if(checkCurrentDay == x){
            data.add(ChartData("${checkCurrentDay}th", holdSnapshotData.first.distance, Colors.deepOrange));
            average_m += holdSnapshotData.first.distance;
            average_s += holdSnapshotData.first.average_speed;
            holdSnapshotData.removeAt(0);
            checkCurrentDay -= 1;
          }
        }

        average = average_s / size;
        String convertAverage = average.toStringAsFixed(1);
        average = double.parse(convertAverage);

        aver_m = average_m / size;
        String convertAverage_m = aver_m.toStringAsFixed(2);
        aver_m = double.parse(convertAverage_m);
      }
      else if (snapshot.docs.isEmpty){ // if a user has no data yet (new account)
        testString = "user does not have data";
        d = DateTime.now();
        currentDay = GetWeekDayAsInteger().convertTimeStamp(d);

        for (int i = 0; i < 7; i++){
          data.add(ChartData(currentDay.toString(), 0.0, Colors.deepOrange));
          currentDay -= 1;
        }
      }

      setState(() {
        chartData = data.reversed.toList();
        avg_miles = aver_m;
        avg_speed = average;
        tStamp = tS;
        test = testString;
        holdSData = holdSnapshotData;
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
                            text: '${avg_speed.toStringAsFixed(1)} MPH ',
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
                            widget: Text("${avg_speed.toStringAsFixed(1)} MPH",
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

class HoldSnapData {
  HoldSnapData(this.day, this.distance, this.average_speed);
  final int day;
  final double distance;
  final double average_speed;
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




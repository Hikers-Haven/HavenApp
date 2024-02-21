import 'package:flutter/material.dart';
import 'package:mapbox_2/customAppBar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class FourthPage extends StatelessWidget {
  const FourthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData = [
      ChartData(1, 7.2),
      ChartData(2, 6.7),
      ChartData(3, 9.8),
      ChartData(4, 8.8),
      ChartData(5, 9.1),
      ChartData(6, 7.3),
      ChartData(7, 6.8),
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
        appBar: customAppBar(),
        backgroundColor: Colors.green[900],
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
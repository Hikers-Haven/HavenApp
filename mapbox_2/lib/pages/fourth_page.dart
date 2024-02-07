import 'package:flutter/material.dart';
import 'package:mapbox_2/customAppBar.dart';
class FourthPage extends StatelessWidget{
  const FourthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: customAppBar(),
      backgroundColor: Colors.green[200],
      body: Center(
        child: Text('CYCLING STATISTICS HERE?'),
    ));
  }
}
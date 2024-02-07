import 'package:flutter/material.dart';
import 'package:mapbox_2/customAppBar.dart';

class ThirdPage extends StatelessWidget{
  const ThirdPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: customAppBar(),
      backgroundColor: Colors.green[200],
      body: Center(
        child: Text('COMMUNITY REVIEWS HERE?'),
    ));
  }
}
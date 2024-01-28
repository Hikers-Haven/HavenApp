import 'package:flutter/material.dart';
import 'package:mapbox_2/customAppBar.dart';

class FirstPage extends StatelessWidget{
  const FirstPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: customAppBar(),
      backgroundColor: Colors.green[200],
      body: Center(
        child: Text('FORUM PAGE STUFF'),
    ));
  }
}
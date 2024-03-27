import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trail Alerts'),
      ),
      body: WebView(
        initialUrl: 'https://www.foxvalleyparkdistrict.org/parks-trails/trails/#closures-maintenance',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}

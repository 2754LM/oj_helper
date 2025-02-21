import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class OierPage extends StatefulWidget {
  @override
  State<OierPage> createState() {
    return _OierPageState();
  }
}

class _OierPageState extends State<OierPage> {
  late InAppWebViewController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oierdb'),
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.blue,
          iconSize: 35,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri("https://oier.baoshuo.dev/")),
        onWebViewCreated: (controller) {
          this.controller = controller;
        },
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          cacheEnabled: true,
        ),
      ),
    );
  }
}

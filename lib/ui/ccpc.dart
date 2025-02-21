import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CcpcPage extends StatefulWidget {
  @override
  State<CcpcPage> createState() {
    return _CcpcPageState();
  }
}

class _CcpcPageState extends State<CcpcPage> {
  late InAppWebViewController controller;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CcpcFinder'),
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
        initialUrlRequest: URLRequest(url: WebUri("https://cpcfinder.com/")),
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

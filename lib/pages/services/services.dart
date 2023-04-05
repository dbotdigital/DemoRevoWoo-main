import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({Key? key}) : super(key: key);

  @override
  State<ServicePage> createState() => _ServicePageState();
}

bool isLoading = true;

class _ServicePageState extends State<ServicePage> {
  @override
  void initState() {
    isLoading = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
      ),
      body: Center(
        child: WebView(
          backgroundColor: Colors.white,
          initialUrl: 'https://smartdealshops.com/services/',
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}

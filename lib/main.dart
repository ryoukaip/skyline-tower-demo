import 'package:flutter/material.dart';
import 'package:skyline_tower2/screens/login_screen.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;
  StreamSubscription? _linkSub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    // Listen to deep link streams
    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      if (uri != null) {
        final status = uri.queryParameters['status'];
        final orderId = uri.queryParameters['order_id'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentResultScreen(status: status ?? 'unknown', orderId: orderId ?? ''),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const LoginScreen(),
    );
  }
}

class PaymentResultScreen extends StatelessWidget {
  final String status;
  final String orderId;

  const PaymentResultScreen({super.key, required this.status, required this.orderId});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Kết quả thanh toán')),
    body: Center(child: Text('Status: $status\nOrder ID: $orderId')),
  );
}

import 'package:flutter/material.dart';
import 'package:skyline_tower2/components/pocketbase_service.dart';
import 'package:skyline_tower2/screens/login_screen.dart';
import 'package:skyline_tower2/layouts/main_layout.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PocketBaseService.init();

  bool loggedIn = false;
  if (PocketBaseService().isLoggedIn) {
    try {
      await PocketBaseService().pb.collection('users').authRefresh();
      loggedIn = true;
    } catch (e) {
      // token invalid, force logout
      PocketBaseService().logout();
    }
  }

  runApp(MyApp(isLoggedIn: loggedIn));
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

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
    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      if (uri != null) {
        final status = uri.queryParameters['status'];
        final orderId = uri.queryParameters['order_id'];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => PaymentResultScreen(
                  status: status ?? 'unknown',
                  orderId: orderId ?? '',
                ),
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
      title: 'Skyline Tower',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: widget.isLoggedIn ? const MainLayout() : const LoginScreen(),
    );
  }
}

class PaymentResultScreen extends StatelessWidget {
  final String status;
  final String orderId;

  const PaymentResultScreen({
    super.key,
    required this.status,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Kết quả thanh toán')),
    body: Center(child: Text('Status: $status\nOrder ID: $orderId')),
  );
}

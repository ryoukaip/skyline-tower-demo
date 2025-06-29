import 'package:flutter/material.dart';
import 'package:skyline_tower2/screens/bills_screen.dart';
import 'package:skyline_tower2/screens/home_screen.dart';
import 'package:skyline_tower2/screens/personal_screen.dart';
import 'package:skyline_tower2/screens/services_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeScreen(),
    ServicesScreen(),
    BillsScreen(),
    PersonalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.handyman), label: 'Dịch vụ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Hóa đơn'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }
}

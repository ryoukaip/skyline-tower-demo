// lib/main_layout.dart
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
  // Make 'screens' a late final variable instead of const
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    // Initialize the list of screens here, so we can pass a function
    // to the HomeScreen constructor.
    screens = [
      HomeScreen(onNavigateToTab: changeTab), // Pass the callback here
      const ServicesScreen(),
      const BillsScreen(),
      const PersonalScreen(),
    ];
  }

  // This function will be called by HomeScreen to change the tab
  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) {
          // This allows direct user taps on the navigation bar
          changeTab(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.handyman), label: 'Dịch vụ'),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Hóa đơn',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cá nhân'),
        ],
      ),
    );
  }
}

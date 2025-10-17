// lib/screens/services_screen.dart
import 'package:flutter/material.dart';
import 'package:skyline_tower2/components/selection_grid.dart';
import 'package:skyline_tower2/screens/request_form_screen.dart';
import 'package:skyline_tower2/screens/user_opinion_screen.dart';
// Make sure you have your AllNewsScreen imported if you want to navigate to it
import 'package:skyline_tower2/screens/all_news_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The lists remain the same
    final List<Map<String, dynamic>> allServices = [
      {'icon': Icons.payment, 'label': 'Phí dịch vụ'},
      {'icon': Icons.water_drop, 'label': 'Phí nước'},
      {'icon': Icons.flash_on, 'label': 'Phí điện'},
      {'icon': Icons.directions_bike, 'label': 'Phương tiện'},
      {'icon': Icons.swap_horiz, 'label': 'Chuyển đồ'},
      {'icon': Icons.build, 'label': 'Sửa chữa'},
      {'icon': Icons.event_available, 'label': 'Đặt tiện ích'},
      {'icon': Icons.credit_card, 'label': 'Đăng ký thẻ'},
    ];

    final List<Map<String, dynamic>> newsItems = [
      {'icon': Icons.article, 'label': 'Bảng tin'},
      {'icon': Icons.feedback, 'label': 'Ý kiến'},
    ];

    Widget sectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dịch vụ')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Temporary FAB pressed');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ServiceRegistrationForm()),
          );
        },
        child: Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle('Dịch vụ'),
            // This grid handles service requests, but not opinions
            SelectionGrid(
              items: allServices,
              onItemTap: (item) {
                // You can handle other service taps here if needed
                print('${item['label']} tapped');
              },
            ),

            sectionTitle('Tin tức'),
            // *** FIX: The onItemTap handler is now on the correct grid ***
            SelectionGrid(
              items: newsItems,
              crossAxisCount: 4,
              onItemTap: (item) {
                // *** FIX: Add navigation logic inside the handler ***
                if (item['label'] == "Ý kiến") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserOpinionScreen(),
                    ),
                  );
                } else if (item['label'] == "Bảng tin") {
                  // This is how you would handle the other button
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllNewsScreen(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

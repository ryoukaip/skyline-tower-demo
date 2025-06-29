// import 'package:flutter/material.dart';

// class ServicesScreen extends StatelessWidget {
//   const ServicesScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(child: Text('Dịch vụ', style: TextStyle(fontSize: 32)));
//   }
// }

import 'package:flutter/material.dart';
import 'package:skyline_tower2/components/selection_grid.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> favoriteServices = [
      {'icon': Icons.payment, 'label': 'Phí dịch vụ'},
      {'icon': Icons.water_drop, 'label': 'Phí nước'},
      {'icon': Icons.article, 'label': 'Bảng tin'},
      {'icon': Icons.feedback, 'label': 'Ý kiến'},
    ];

    final List<Map<String, dynamic>> allServices = [
      {'icon': Icons.payment, 'label': 'Phí dịch vụ'},
      {'icon': Icons.water_drop, 'label': 'Phí nước'},
      {'icon': Icons.flash_on, 'label': 'Phí điện'},
      {'icon': Icons.directions_bike, 'label': 'Phương tiện'},
      {'icon': Icons.swap_horiz, 'label': 'Đăng ký chuyển đồ'},
      {'icon': Icons.build, 'label': 'Đăng ký sửa chữa'},
      {'icon': Icons.event_available, 'label': 'Đặt tiện ích'},
      {'icon': Icons.credit_card, 'label': 'Đăng ký thẻ'},
    ];

    final List<Map<String, dynamic>> newsItems = [
      {'icon': Icons.article, 'label': 'Bảng tin'},
      {'icon': Icons.event, 'label': 'Sự kiện'},
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
            if (title == 'Tiện ích yêu thích')
              TextButton(onPressed: () {}, child: const Text('Chỉnh sửa')),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dịch vụ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle('Tiện ích yêu thích'),
            SelectionGrid(items: favoriteServices,),

            sectionTitle('Dịch vụ'),
            SelectionGrid(items: allServices),

            sectionTitle('Tin tức'),
            SelectionGrid(items: newsItems, crossAxisCount: 3),
          ],
        ),
      ),
    );
  }
}

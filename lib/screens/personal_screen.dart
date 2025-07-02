// import 'package:flutter/material.dart';

// class PersonalScreen extends StatelessWidget {
//   const PersonalScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(child: Text('Cá nhân', style: TextStyle(fontSize: 32)));
//   }
// }

import 'package:flutter/material.dart';
import 'package:skyline_tower2/components/selection_grid.dart';

class PersonalScreen extends StatelessWidget {
  const PersonalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userName = 'Nguyễn Văn A';

    final List<Map<String, dynamic>> personalInfoItems = [
      {'icon': Icons.person, 'label': 'Thông tin cá nhân'},
      {'icon': Icons.home, 'label': 'Thông tin căn hộ'},
      {'icon': Icons.group, 'label': 'Thông tin nhân khẩu'},
      {'icon': Icons.apartment, 'label': 'Tổng quan tòa nhà'},
      {'icon': Icons.lock, 'label': 'Thay đổi mật khẩu'},
      {'icon': Icons.credit_card, 'label': 'Thẻ cư dân, căn hộ'},
    ];

    final List<Map<String, dynamic>> settingsItems = [
      {'icon': Icons.book, 'label': 'Sổ tay'},
      {'icon': Icons.photo_library, 'label': 'Thư viện'},
      {'icon': Icons.help_outline, 'label': 'Hướng dẫn sử dụng'},
      {'icon': Icons.language, 'label': 'Ngôn ngữ'},
      {'icon': Icons.system_update, 'label': 'Nâng cấp ứng dụng'},
      {'icon': Icons.logout, 'label': 'Đăng xuất'},
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: InkWell(
                onTap: () {
                  // Action for edit profile
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Xin chào $userName',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Edit info
                        },
                        child: const Text('Chỉnh sửa thông tin'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Thông tin và bảo mật',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SelectionGrid(items: personalInfoItems, crossAxisCount: 4,),
            const SizedBox(height: 24),
            const Text(
              'Quản lý và thiết lập',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SelectionGrid(items: settingsItems, crossAxisCount: 4,)
          ],
        ),
      ),
    );
  }
}

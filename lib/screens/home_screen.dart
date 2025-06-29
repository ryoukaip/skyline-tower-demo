import 'package:flutter/material.dart';
import 'package:skyline_tower2/components/auto_scroll_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userName = 'Nguyễn Văn A';
    final String aptName = 'Căn hộ 12B';
    final String towerInfo = 'Tầng 12, Tòa A';
    final double balance = 1500.00;
    final double dueFee = 2000000000000;
    final List<Map<String, dynamic>> services = List.generate(
      8,
      (i) => {'icon': Icons.build, 'label': 'Dịch vụ ${i + 1}'},
    );
    final List<Map<String, String>> posts = List.generate(
      4,
      (i) => {'image': 'assets/post${i + 1}.jpg', 'label': 'Bài viết ${i + 1}'},
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào $userName',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aptName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(towerInfo, style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: Colors.green[50],
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AutoScrollText(
                                    text: 'Số dư căn hộ',
                                    style: TextStyle(color: Colors.green),
                                    height: 20,
                                  ),
                                  const SizedBox(height: 8),
                                  AutoScrollText(
                                    text: '\$${balance.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    height: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            color: Colors.red[50],
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AutoScrollText(
                                    text: 'Phí cần thanh toán',
                                    style: TextStyle(color: Colors.red),
                                    height: 20,
                                  ),
                                  const SizedBox(height: 8),
                                  AutoScrollText(
                                    text: '\$${dueFee.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    height: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Dịch vụ yêu thích',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('Chỉnh sửa')),
              ],
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (_, idx) {
                final s = services[idx];
                return InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(child: Icon(s['icon'])),
                        const SizedBox(height: 4),
                        Text(
                          s['label'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: CarouselView(
                itemExtent: 300,
                shrinkExtent: 200,
                padding: EdgeInsets.symmetric(horizontal: 8),
                itemSnapping: true,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                children: List.generate(
                  5,
                  (i) => Container(
                    margin: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue[(i + 1) * 100],
                    ),
                    child: Center(
                      child: Text(
                        'Carousel Item ${i + 1}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Thông tin',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              children:
                  posts.map((p) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior:
                          Clip.antiAlias, // Important to clip the ripple
                      child: InkWell(
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Ink.image(
                              image: AssetImage(p['image']!),
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                p['label']!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

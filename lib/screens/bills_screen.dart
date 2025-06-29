// import 'package:flutter/material.dart';

// class BillsScreen extends StatelessWidget {
//   const BillsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Center(child: Text('Hóa đơn', style: TextStyle(fontSize: 32)));
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skyline_tower2/screens/bills_screeens_details/bill_screen_water_details.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  // Hàm mô phỏng gọi database (trong thực tế bạn thay bằng API call hoặc DB)
  Future<Map<String, List<Map<String, dynamic>>>> fetchBills() async {
    await Future.delayed(const Duration(seconds: 2)); // giả lập delay

    final unpaidBills = [
      {
        'type': 'nước',
        'icon': Icons.water_drop,
        'title': 'Hóa đơn nước',
        'owner': 'Nguyễn Văn A',
        'code': 'HDN001',
        'amount': 150000,
      },
      {
        'type': 'điện',
        'icon': Icons.flash_on,
        'title': 'Hóa đơn điện',
        'owner': 'Nguyễn Văn A',
        'code': 'HDD002',
        'amount': 320000,
      },
    ];

    final paidBills = [
      {
        'type': 'chung cư',
        'icon': Icons.apartment,
        'title': 'Phí quản lý',
        'owner': 'Nguyễn Văn A',
        'code': 'HDC003',
        'amount': 500000,
        'paidDate': DateTime(2025, 5, 12),
      },
      {
        'type': 'nước',
        'icon': Icons.water_drop,
        'title': 'Hóa đơn nước',
        'owner': 'Nguyễn Văn A',
        'code': 'HDN999',
        'amount': 140000,
        'paidDate': DateTime(2025, 4, 30),
      },
    ];

    return {'unpaid': unpaidBills, 'paid': paidBills};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hóa đơn')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Bạn đã nhấn nút FAB');
          // Thêm các hành động khác ở đây nếu cần
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BillWaterDetailsScreen(
                    bill: {
                      'title': 'Hóa đơn nước tháng 6',
                      'code': 'HDN123',
                      'amount': 150000,
                      'isPaid': false, // hoặc true nếu đã thanh toán
                    },
                  ),
            ),
          );
        },
        tooltip: 'Thêm',
        child: Icon(Icons.add),
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: fetchBills(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Lỗi khi tải dữ liệu'));
          }

          final unpaidBills = snapshot.data!['unpaid']!;
          final paidBills = snapshot.data!['paid']!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hóa đơn cần thanh toán',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...unpaidBills.map(
                  (bill) => _buildBillItem(bill, isPaid: false),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Hóa đơn đã thanh toán',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...paidBills.map((bill) => _buildBillItem(bill, isPaid: true)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBillItem(Map<String, dynamic> bill, {required bool isPaid}) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias, // Ensures ripple doesn't overflow
      child: InkWell(
        onTap: () {
          // Xử lý khi nhấn vào hóa đơn
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[50],
                child: Icon(bill['icon']),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Chủ: ${bill['owner']}'),
                    Text('Mã: ${bill['code']}'),
                    if (isPaid && bill['paidDate'] != null)
                      Text(
                        'Ngày thanh toán: ${dateFormat.format(bill['paidDate'])}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
              Text(
                '${bill['amount']}đ',
                style: TextStyle(
                  color: isPaid ? Colors.black : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

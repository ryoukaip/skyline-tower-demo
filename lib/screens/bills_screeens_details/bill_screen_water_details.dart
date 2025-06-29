import 'package:flutter/material.dart';

class BillWaterDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> bill;

  const BillWaterDetailsScreen({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final bool isPaid = bill['isPaid'] == true;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết hóa đơn nước')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(bill),
            const SizedBox(height: 24),
            _buildTotalCard(bill['amount']),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (isPaid) {
                    Navigator.pop(context);
                  } else {
                    // Xử lý thanh toán ở đây
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đang xử lý thanh toán...')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPaid ? Colors.grey : Colors.blue,
                ),
                child: Text(isPaid ? 'Quay lại' : 'Thanh toán'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> bill) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Tên hóa đơn', bill['title']),
            const SizedBox(height: 8),
            _buildInfoRow('Mã hóa đơn', bill['code']),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Trạng thái',
              bill['isPaid'] == true ? 'Đã thanh toán' : 'Chưa thanh toán',
              valueColor: bill['isPaid'] == true ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCard(int amount) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tổng:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '$amountđ',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// bills_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:skyline_tower2/components/pocketbase_service.dart';
import 'package:skyline_tower2/screens/bill_screen_details.dart';

// 1. Convert to StatefulWidget
class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  // 2. Store the future in a state variable
  late Future<Map<String, List<Map<String, dynamic>>>> _billsFuture;

  @override
  void initState() {
    super.initState();
    _billsFuture = _fetchBills();
  }

  // Helper to map bill names to icons
  IconData _getIconForBill(String billName) {
    final name = billName.toLowerCase();
    if (name.contains('nước')) return Icons.water_drop;
    if (name.contains('điện')) return Icons.flash_on;
    if (name.contains('quản lý') || name.contains('chung cư'))
      return Icons.apartment;
    if (name.contains('xe')) return Icons.directions_car;
    return Icons.receipt; // Default icon
  }

  // Renamed from fetchBills to _fetchBills
  Future<Map<String, List<Map<String, dynamic>>>> _fetchBills() async {
    // Get the singleton instance of your service
    final pbService = PocketBaseService();

    // Fetch the raw records from the database
    final List<RecordModel> records = await pbService.getInvoices();

    // Prepare lists to hold categorized bills
    final List<Map<String, dynamic>> unpaidBills = [];
    final List<Map<String, dynamic>> paidBills = [];

    // Process each record and categorize it
    for (var record in records) {
      // Since we used `expand`, the related apartment record is nested.
      // We safely access it here.
      final apartmentRecord = record.expand['can_ho']?.first;

      final billData = {
        'id': record.id,
        'title': record.data['ten_hoa_don'] ?? 'Không có tên',
        'apartment_code':
            apartmentRecord?.data['ma_can'] ?? 'N/A', // <-- Get apartment code
        'code': record.data['ma_hoa_don'] ?? 'N/A',
        'amount': record.data['tong_tien'] ?? 0,
        'status': record.data['tinh_trang'] ?? '',
        'created': DateTime.parse(record.created),
        'record': record, // Pass the full record for details screen
      };

      if (billData['status'] == 'da_thanh_toan') {
        paidBills.add(billData);
      } else {
        // 'chua_thanh_toan' and 'qua_han' go to unpaid
        unpaidBills.add(billData);
      }
    }

    return {'unpaid': unpaidBills, 'paid': paidBills};
  }

  // 3. Create a function to handle navigation and refresh
  void _navigateToDetails(Map<String, dynamic> bill) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BillWaterDetailsScreen(billRecord: bill['record']),
      ),
    );
    if (result == true) {
      setState(() {
        _billsFuture = _fetchBills();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hóa đơn')),
      // The FAB can be used for a "Create Bill" screen in the future.
      // For now, its functionality is unchanged.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('FAB pressed - implement create bill feature here.');
        },
        tooltip: 'Thêm',
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _billsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi khi tải dữ liệu: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData ||
              (snapshot.data!['unpaid']!.isEmpty &&
                  snapshot.data!['paid']!.isEmpty)) {
            return const Center(child: Text('Không tìm thấy hóa đơn nào.'));
          }

          final unpaidBills = snapshot.data!['unpaid']!;
          final paidBills = snapshot.data!['paid']!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _billsFuture = _fetchBills();
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (unpaidBills.isNotEmpty) ...[
                    const Text(
                      'Hóa đơn cần thanh toán',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...unpaidBills.map(
                      (bill) => _buildBillItem(context, bill, isPaid: false),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (paidBills.isNotEmpty) ...[
                    const Text(
                      'Hóa đơn đã thanh toán',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...paidBills.map(
                      (bill) => _buildBillItem(context, bill, isPaid: true),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 4. Update the onTap handler in _buildBillItem
  Widget _buildBillItem(
    BuildContext context,
    Map<String, dynamic> bill, {
    required bool isPaid,
  }) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final amountFormat = NumberFormat.decimalPattern('vi_VN');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _navigateToDetails(bill);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue[50],
                child: Icon(_getIconForBill(bill['title'])), // Dynamic icon
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
                    // --- MODIFICATION HERE: "Chủ" changed to "Căn hộ" ---
                    Text('Căn hộ: ${bill['apartment_code']}'),
                    Text('Mã: ${bill['code']}'),
                    if (isPaid)
                      Text(
                        'Ngày tạo: ${dateFormat.format(bill['created'])}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${amountFormat.format(bill['amount'])}đ',
                style: TextStyle(
                  color:
                      isPaid
                          ? Colors.black
                          : (bill['status'] == 'qua_han'
                              ? Colors.orange.shade800
                              : Colors.red),
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

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:skyline_tower2/components/pocketbase_service.dart'; // Import service
import 'package:skyline_tower2/components/web_view_screen_vnpay.dart';

class BillWaterDetailsScreen extends StatefulWidget {
  final RecordModel billRecord;

  const BillWaterDetailsScreen({super.key, required this.billRecord});

  @override
  State<BillWaterDetailsScreen> createState() => _BillWaterDetailsScreenState();
}

class _BillWaterDetailsScreenState extends State<BillWaterDetailsScreen> {
  bool _isProcessingPayment = false;

  Future<void> _handlePayment() async {
    setState(() {
      _isProcessingPayment = true;
    });

    try {
      final String apiUrl = 'http://192.168.1.4:5000/create_payment';
      final int amount = (widget.billRecord.data['tong_tien'] as num).toInt();
      final String orderDesc =
          '${widget.billRecord.data['ten_hoa_don']} - ${widget.billRecord.data['ma_hoa_don']}';

      final Map<String, dynamic> payload = {
        'amount': amount,
        'order_desc': orderDesc,
        'bank_code': '',
        'language': 'vn',
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          final String paymentUrl = data['payment_url'];
          final result = await Navigator.push<String>(
            context,
            MaterialPageRoute(
              builder:
                  (context) => WebViewScreenVNPAY(
                    url: paymentUrl,
                    title: 'Thanh toán VNPAY',
                  ),
            ),
          );

          if (result == 'success') {
            await _updateBillStatus();
          } else {
            print('Giao dịch đã bị hủy hoặc thất bại.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Giao dịch đã bị hủy hoặc thất bại.'),
              ),
            );
          }
        } else {
          print('Lỗi: ${data['message'] ?? 'Không thể tạo thanh toán'}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lỗi: ${data['message'] ?? 'Không thể tạo thanh toán'}',
              ),
            ),
          );
        }
      } else {
        print('Lỗi kết nối server: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi kết nối server: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Lỗi: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }

  Future<void> _updateBillStatus() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thanh toán thành công! Đang cập nhật hóa đơn...'),
        ),
      );

      // --- MODIFICATION START ---
      // The old direct call to PocketBase is replaced with a call to our secure Flask backend.

      final String flaskApiUrl =
          'http://192.168.1.4:5000/update_invoice_status';

      final response = await http.post(
        Uri.parse(flaskApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'record_id': widget.billRecord.id}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Success! The backend confirmed the update.
        Navigator.of(context).pop(true); // Pop and signal refresh
      } else {
        // The backend returned an error.
        final responseData = jsonDecode(response.body);
        final errorMessage =
            responseData['message'] ?? 'Lỗi không xác định từ server.';
        throw Exception('Failed to update invoice: $errorMessage');
      }
      // --- MODIFICATION END ---
    } catch (e) {
      print('Lỗi cập nhật hóa đơn: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi cập nhật hóa đơn: $e')));
    }
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'da_thanh_toan':
        return {'text': 'Đã thanh toán', 'color': Colors.green};
      case 'qua_han':
        return {'text': 'Quá hạn', 'color': Colors.orange.shade800};
      case 'chua_thanh_toan':
      default:
        return {'text': 'Chưa thanh toán', 'color': Colors.red};
    }
  }

  @override
  Widget build(BuildContext context) {
    final String statusValue = widget.billRecord.data['tinh_trang'];
    final bool isPaid = statusValue == 'da_thanh_toan';
    final statusInfo = _getStatusInfo(statusValue);

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết hóa đơn')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(widget.billRecord, statusInfo),
            const SizedBox(height: 24),
            _buildTotalCard(
              (widget.billRecord.data['tong_tien'] as num).toInt(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (isPaid || _isProcessingPayment) ? null : _handlePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPaid ? Colors.grey : Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child:
                    _isProcessingPayment
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : Text(isPaid ? 'Đã thanh toán' : 'Thanh toán'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(RecordModel record, Map<String, dynamic> statusInfo) {
    final apartment = record.expand['can_ho']?.first;
    final apartmentCode = apartment?.data['ma_can'] ?? 'N/A';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Tên hóa đơn', record.data['ten_hoa_don']),
            const Divider(height: 16),
            _buildInfoRow('Mã hóa đơn', record.data['ma_hoa_don']),
            const Divider(height: 16),
            _buildInfoRow('Căn hộ', apartmentCode),
            const Divider(height: 16),
            _buildInfoRow(
              'Trạng thái',
              statusInfo['text'],
              valueColor: statusInfo['color'],
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
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
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
    final amountFormat = NumberFormat.decimalPattern('vi_VN');

    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tổng tiền',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '${amountFormat.format(amount)}đ',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/screens/user_opinion_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:skyline_tower2/components/pocketbase_service.dart';

class UserOpinionScreen extends StatefulWidget {
  const UserOpinionScreen({super.key});

  @override
  State<UserOpinionScreen> createState() => _UserOpinionScreenState();
}

class _UserOpinionScreenState extends State<UserOpinionScreen> {
  late Future<List<RecordModel>> _opinionsFuture;

  @override
  void initState() {
    super.initState();
    _opinionsFuture = PocketBaseService().getUserOpinions();
  }

  // Refreshes the list of opinions by re-fetching from the server
  void _refreshOpinions() {
    setState(() {
      _opinionsFuture = PocketBaseService().getUserOpinions();
    });
  }

  // Shows the dialog for adding a new opinion
  void _showAddOpinionDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Gửi ý kiến của bạn'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: "Nhập nội dung..."),
            minLines: 3,
            maxLines: 5,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Gửi'),
              onPressed: () async {
                final content = textController.text.trim();
                if (content.isEmpty) return;

                // Close the dialog
                Navigator.of(dialogContext).pop();

                try {
                  // Show a loading indicator
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Đang gửi...')));
                  await PocketBaseService().createUserOpinion(content);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gửi ý kiến thành công!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Refresh the list
                  _refreshOpinions();
                } catch (e) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ý kiến của bạn')),
      body: FutureBuilder<List<RecordModel>>(
        future: _opinionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Bạn chưa gửi ý kiến nào.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final opinions = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: opinions.length,
            itemBuilder: (context, index) {
              return _buildOpinionCard(opinions[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOpinionDialog(context),
        tooltip: 'Gửi ý kiến mới',
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  // Widget to build a single opinion card
  Widget _buildOpinionCard(RecordModel opinion) {
    final userContent = opinion.data['noi_dung'] ?? 'N/A';
    final adminReply = opinion.data['phan_hoi'] ?? '';
    final createdDate = DateTime.tryParse(opinion.created) ?? DateTime.now();
    final formattedDate = DateFormat('HH:mm - dd/MM/yyyy').format(createdDate);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User's Opinion
            Text(
              userContent,
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              formattedDate,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 12),

            // Admin's Reply
            if (adminReply.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Phản hồi từ Ban Quản Lý:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(adminReply, style: const TextStyle(height: 1.4)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

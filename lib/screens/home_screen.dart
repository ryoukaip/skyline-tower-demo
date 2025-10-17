// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for number formatting
import 'package:pocketbase/pocketbase.dart';
import 'package:skyline_tower2/components/auto_scroll_text.dart';
import 'package:skyline_tower2/components/selection_grid.dart';
import 'package:skyline_tower2/components/web_view_screen.dart';
import 'package:skyline_tower2/screens/all_news_screen.dart';
import 'package:skyline_tower2/screens/favorite_services_screen.dart';
import 'package:skyline_tower2/components/pocketbase_service.dart';

class HomeScreen extends StatefulWidget {
  // Add a callback function to the constructor to handle navigation
  final Function(int) onNavigateToTab;

  const HomeScreen({super.key, required this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State variables to hold data-fetching operations
  late Future<List<RecordModel>> _newsFuture;
  late Future<List<RecordModel>> _favoriteServicesFuture;
  late Future<List<RecordModel>> _invoicesFuture;

  @override
  void initState() {
    super.initState();
    // Fetch all necessary data when the widget is first created
    final pbService = PocketBaseService();
    _newsFuture = pbService.getNews();
    _invoicesFuture = pbService.getInvoices();
    _loadFavoriteServices();
  }

  // Method to load or reload favorite services, e.g., after returning from the edit screen
  void _loadFavoriteServices() {
    setState(() {
      _favoriteServicesFuture = PocketBaseService().getFavorites();
    });
  }

  // --- WIDGET BUILDER: Invoice Summary Card ---
  // This widget dynamically calculates the total due fee and handles navigation.
  Widget _buildInvoiceSummaryCard() {
    return FutureBuilder<List<RecordModel>>(
      future: _invoicesFuture,
      builder: (context, snapshot) {
        double totalDue = 0.0;
        Widget amountWidget;

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while fetching data
          amountWidget = const SizedBox(
            height: 24,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
          );
        } else if (snapshot.hasData) {
          final invoices = snapshot.data!;
          // Calculate the total of all unpaid or overdue bills
          for (var invoice in invoices) {
            if (invoice.data['tinh_trang'] != 'da_thanh_toan') {
              // Ensure the 'tong_tien' field is treated as a number
              totalDue +=
                  (invoice.data['tong_tien'] as num?)?.toDouble() ?? 0.0;
            }
          }

          // Format the number for Vietnamese currency display
          final amountFormat = NumberFormat.decimalPattern('vi_VN');
          amountWidget = AutoScrollText(
            text: '${amountFormat.format(totalDue)}đ',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            height: 24,
          );
        } else {
          // Handle error state
          amountWidget = const AutoScrollText(
            text: 'Không tải được dữ liệu',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            height: 24,
          );
        }

        // The main card is wrapped in InkWell to make it tappable
        return Card(
          color: totalDue > 0 ? Colors.red[50] : Colors.green[50],
          child: InkWell(
            onTap: () {
              // Use the callback to navigate to the BillsScreen (index 2 in MainLayout)
              widget.onNavigateToTab(2);
            },
            borderRadius: BorderRadius.circular(
              8,
            ), // Match card's border radius
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoScrollText(
                    text: 'Phí cần thanh toán',
                    style: TextStyle(
                      color: totalDue > 0 ? Colors.red : Colors.green,
                    ),
                    height: 20,
                  ),
                  const SizedBox(height: 8),
                  amountWidget, // Display the calculated amount or loading state
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET BUILDER: Favorite Services Section ---
  // This widget dynamically builds the grid of favorite services.
  Widget _buildFavoriteServicesSection() {
    return FutureBuilder<List<RecordModel>>(
      future: _favoriteServicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Text('Chưa có dịch vụ yêu thích nào được chọn.'),
            ),
          );
        }

        final favoriteRecords = snapshot.data!;

        // Transform data for the SelectionGrid widget
        final servicesForGrid =
            favoriteRecords.map((record) {
              final serviceData = record.expand['dich_vu']![0];
              final serviceName =
                  serviceData.data['ten_dich_vu'] ?? 'Không có tên';
              return {
                'icon': _getIconForService(serviceName),
                'label': serviceName,
              };
            }).toList();

        final displayedServices = servicesForGrid.take(4).toList();

        return SelectionGrid(
          items: displayedServices,
          onItemTap: _onServiceTap,
        );
      },
    );
  }

  // --- WIDGET BUILDER: News Section ---
  // This widget builds the list of latest news articles.
  Widget _buildNewsSection() {
    return FutureBuilder<List<RecordModel>>(
      future: _newsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi tải tin tức: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có tin tức nào.'));
        }

        final newsItems = snapshot.data!.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...newsItems.map((news) {
              final title = news.data['title'] ?? 'Không có tiêu đề';
              final htmlLink = news.data['html_link'] ?? '';
              final thumbnailFilename = news.data['thumbnail'];
              String? thumbnailUrl;
              if (thumbnailFilename != null && thumbnailFilename.isNotEmpty) {
                thumbnailUrl =
                    PocketBaseService().pb
                        .getFileUrl(news, thumbnailFilename)
                        .toString();
              }

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    if (htmlLink.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  WebViewScreen(url: htmlLink, title: title),
                        ),
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (thumbnailUrl != null)
                        Ink.image(
                          image: NetworkImage(thumbnailUrl),
                          height: 160,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(
                          height: 160,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.article,
                            color: Colors.grey,
                            size: 50,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllNewsScreen(),
                    ),
                  );
                },
                child: const Text('Xem thêm'),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- HELPER METHOD: Get Icon for Service ---
  IconData _getIconForService(String serviceName) {
    switch (serviceName) {
      case 'Sửa chữa điện':
        return Icons.electrical_services;
      case 'Dọn dẹp vệ sinh':
        return Icons.cleaning_services;
      case 'Giặt là':
        return Icons.local_laundry_service;
      case 'Sửa ống nước':
        return Icons.plumbing;
      default:
        return Icons.apps; // Fallback icon
    }
  }

  // --- HELPER METHOD: Service Tap Handler ---
  void _onServiceTap(Map<String, dynamic> item) {
    final String label = item['label'];
    // In a real app, you would navigate to different screens based on the label.
    // For now, we'll just show a placeholder message.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chức năng cho "$label" sắp ra mắt!')),
    );
  }

  // --- MAIN BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    // Placeholder user data
    const String userName = 'Nguyễn Văn A';
    const String aptName = 'Căn hộ 12B';
    const String towerInfo = 'Tầng 12, Tòa A';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Allow user to pull-to-refresh data
            setState(() {
              _invoicesFuture = PocketBaseService().getInvoices();
              _newsFuture = PocketBaseService().getNews();
              _loadFavoriteServices();
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                        Text(
                          towerInfo,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        _buildInvoiceSummaryCard(), // Use the dynamic invoice card
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Text(
                      'Dịch vụ yêu thích',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const FavoriteServicesScreen(),
                          ),
                        );
                        // Reload services when the user returns
                        _loadFavoriteServices();
                      },
                      child: const Text('Chỉnh sửa'),
                    ),
                  ],
                ),
                _buildFavoriteServicesSection(),
                const SizedBox(height: 24),
                const Text(
                  'Thông tin',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildNewsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

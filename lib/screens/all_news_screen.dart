// lib/screens/all_news_screen.dart

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:skyline_tower2/components/news_card.dart'; // Import the new widget
import 'package:skyline_tower2/components/pocketbase_service.dart';

class AllNewsScreen extends StatefulWidget {
  const AllNewsScreen({super.key});

  @override
  State<AllNewsScreen> createState() => _AllNewsScreenState();
}

class _AllNewsScreenState extends State<AllNewsScreen> {
  final List<RecordModel> _newsItems = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final int _perPage = 5;

  @override
  void initState() {
    super.initState();
    // Fetch the first batch of news when the screen loads
    _fetchNews();
  }

  // Method to fetch news from PocketBase
  Future<void> _fetchNews() async {
    // Prevent multiple fetches at the same time
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newItems = await PocketBaseService().getNewsPaginated(
        page: _currentPage,
        perPage: _perPage,
      );

      // If fewer items are returned than requested, we've reached the end
      if (newItems.length < _perPage) {
        _hasMore = false;
        // Show a snackbar only if the user is trying to load more, not on initial load
        if (_currentPage > 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã hết tin tức'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      setState(() {
        _newsItems.addAll(newItems);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error, e.g., show a snackbar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tải tin tức: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tất cả tin tức')),
      body: ListView.builder(
        // Add one extra item to the list for the "Xem thêm" button or loading indicator
        itemCount: _newsItems.length + 1,
        itemBuilder: (context, index) {
          // If it's the last item in the list
          if (index == _newsItems.length) {
            if (_isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (_hasMore) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: _fetchNews,
                    child: const Text('Xem thêm'),
                  ),
                ),
              );
            }
            // If there's no more news and not loading, show an empty container
            return const SizedBox.shrink();
          }

          // Otherwise, build a NewsCard for the current news item
          final news = _newsItems[index];
          return NewsCard(news: news);
        },
      ),
    );
  }
}

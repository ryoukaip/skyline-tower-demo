// lib/components/news_card.dart

import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:skyline_tower2/components/web_view_screen.dart';
import 'package:skyline_tower2/components/pocketbase_service.dart';

class NewsCard extends StatelessWidget {
  final RecordModel news;

  const NewsCard({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final title = news.data['title'] ?? 'Không có tiêu đề';
    final htmlLink = news.data['html_link'] ?? '';
    final thumbnailFilename = news.data['thumbnail'];

    String? thumbnailUrl;
    if (thumbnailFilename != null && thumbnailFilename.isNotEmpty) {
      thumbnailUrl =
          PocketBaseService().pb.getFileUrl(news, thumbnailFilename).toString();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (htmlLink.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => WebViewScreen(url: htmlLink, title: title),
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
                height: 180,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 180,
                color: Colors.grey[200],
                child: const Icon(Icons.article, color: Colors.grey, size: 50),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
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
  }
}

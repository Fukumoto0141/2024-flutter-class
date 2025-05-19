import 'package:flutter/material.dart';

class BookDetailPage extends StatelessWidget {
  final String title;
  final String author;
  final String review;
  final String? imageUrl;

  const BookDetailPage({
    super.key,
    required this.title,
    required this.author,
    required this.review,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('詳細')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl!, height: 200, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Text('タイトル: $title', style: Theme.of(context).textTheme.titleLarge),
            Text('著者: $author', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Text('感想:', style: Theme.of(context).textTheme.titleSmall),
            Text(review),
          ],
        ),
      ),
    );
  }
}

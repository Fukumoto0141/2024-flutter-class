import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String? imageUrl;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.title,
    required this.author,
    this.imageUrl,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(imageUrl!, width: 50, height: 50, fit: BoxFit.cover),
              )
            : const Icon(Icons.book_outlined),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(author),
        trailing: IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
        onTap: onTap,
      ),
    );
  }
}

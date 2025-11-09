import 'package:flutter/material.dart';

class ProductDetailSheet extends StatelessWidget {
  const ProductDetailSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with back arrow
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              const Text(
                'Book Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: const [
              SectionTitle('Description'),
              SizedBox(height: 6),
              GreyText(
                "Discover the captivating world of literature with this remarkable book. A journey through pages filled with compelling narratives, rich characters, and thought-provoking themes that will transport you to different realms and perspectives.",
              ),
              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 24),
              
              SectionTitle('Book Information'),
              SizedBox(height: 12),
              BulletText("Author: Published Author"),
              BulletText("Publisher: Renowned Publishing House"),
              BulletText("ISBN: 978-3-16-148410-0"),
              BulletText("Pages: 320"),
              BulletText("Language: English"),
              BulletText("Publication Date: 2023"),
              BulletText("Genre: Fiction/Literature"),
              
              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 24),
              
              SectionTitle('Book Specifications'),
              SizedBox(height: 8),
              GreyText("Format: Paperback\nCategory: Fiction\nCondition: New\nDimensions: 8.5 x 5.5 inches\nWeight: 1.2 lbs"),
              
              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 24),
              
              SectionTitle('About This Book'),
              SizedBox(height: 8),
              GreyText("This book features high-quality printing, durable binding, and crisp pages for an enjoyable reading experience. Perfect for book lovers and collectors alike."),
            ],
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black));
  }
}

class GreyText extends StatelessWidget {
  final String text;
  const GreyText(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: Colors.grey, height: 1.4));
  }
}

class BulletText extends StatelessWidget {
  final String text;
  const BulletText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(color: Colors.grey)),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}
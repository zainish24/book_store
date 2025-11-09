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
                'Product details',
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
              SectionTitle('Story'),
              SizedBox(height: 6),
              GreyText(
                "A cool gray cap in soft corduroy. Watch me.' By buying cotton products from Lindex, you’re supporting more responsibly...",
              ),
              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 24),
              SectionTitle('Details'),
              SizedBox(height: 12),
              BulletText("Materials: 100% cotton, and lining Structured"),
              BulletText("Adjustable cotton strap closure"),
              BulletText("High quality embroidery stitching"),
              BulletText("Head circumference: 21” - 24” / 54–62 cm"),
              BulletText("Embroidery stitching"),
              BulletText("One size fits most"),
              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 24),
              SectionTitle('Style Notes'),
              SizedBox(height: 8),
              GreyText("Style: Summer Hat\nDesign: Plain\nFabric: Jersey"),
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
    return Text(text, style: const TextStyle(color: Colors.grey));
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

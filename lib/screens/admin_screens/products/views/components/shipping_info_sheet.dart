import 'package:flutter/material.dart';

class ShippingInfoSheet extends StatelessWidget {
  const ShippingInfoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with back arrow and title
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
                'Shipping methods',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),
              ),
              const Spacer(flex: 2),
              const Icon(Icons.info_outline, size: 20),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children:  [
              const ShippingCard(
                title: 'Standard',
                description: 'Arrives in 5–8 business days',
                price1: '\$4.95',
                price2: 'Free',
                line1: 'Order up to \$49.99:',
                line2: 'Orders \$50 and over:',
                highlightColor: Color(0xFF8855FF),
                isSelected: true,
                note: 'Free with Shoplon Premier',
              ),
              const ShippingCard(
                title: 'Express',
                description: 'Arrives in 2–3 business days',
                price1: '\$14.95',
                highlightColor: Color(0xFFB0E6FF),
                note: 'Free with Shoplon Premier',
              ),
              const FlatShippingRow(
                title: 'Rush',
                description: 'Arrives in 1–2 business days',
                price: '\$21.95',
              ),
              const FlatShippingRow(
                title: 'Truck',
                description: 'Arrives in 2–4 weeks once shipped',
                price: '\$102.50',
              ),
              const SizedBox(height: 16),
              const GreyText(
                  "Rush shipping may not be available for all orders depending on fulfillment location."),
              const SizedBox(height: 12),
              RichText(
                text:const TextSpan(
                  style: TextStyle(color: Colors.grey),
                  children: [
                    TextSpan(text: "Shipping outside of the US? See our "),
                    TextSpan(
                      text: "International shipping",
                      style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: " rates."),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const GreyText(
                  "This item is available for delivery to one of our convenient Collection Points."),
            ],
          ),
        ),
      ],
    );
  }
}

class ShippingCard extends StatelessWidget {
  final String title;
  final String description;
  final String price1;
  final String? price2;
  final String? line1;
  final String? line2;
  final String? note;
  final bool isSelected;
  final Color highlightColor;

  const ShippingCard({
    super.key,
    required this.title,
    required this.description,
    required this.price1,
    this.price2,
    this.line1,
    this.line2,
    this.note,
    this.isSelected = false,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: highlightColor, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            const Icon(Icons.check_circle_outline, size: 20, color: Colors.black),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 6),
        Text(description, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 12),
        if (line1 != null && line2 != null && price2 != null) ...[
          Text(line1!, style: const TextStyle(color: Colors.black)),
          Text(price1, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(line2!, style: const TextStyle(color: Colors.black)),
          Text(price2!, style: const TextStyle(fontWeight: FontWeight.bold)),
        ] else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              Text(price1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        if (note != null)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              note!,
              style: TextStyle(
                color: highlightColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ]),
    );
  }
}

class FlatShippingRow extends StatelessWidget {
  final String title;
  final String description;
  final String price;

  const FlatShippingRow({
    super.key,
    required this.title,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(color: Colors.grey)),
          ]),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
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

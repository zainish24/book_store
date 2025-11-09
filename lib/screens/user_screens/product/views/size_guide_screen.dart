import 'package:flutter/material.dart';

class SizeGuideScreen extends StatefulWidget {
  const SizeGuideScreen({super.key});

  @override
  State<SizeGuideScreen> createState() => _SizeGuideScreenState();
}

class _SizeGuideScreenState extends State<SizeGuideScreen> {
  bool showInches = true; // ✅ By default show Inches (first toggle)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Size guide",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Toggle buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showInches = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: showInches ? const Color(0xFF7B61FF) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        border: Border.all(color: const Color(0xFFECECEC)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Inches",
                        style: TextStyle(
                          color: showInches ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showInches = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: !showInches ? const Color(0xFF7B61FF) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: Border.all(color: const Color(0xFFECECEC)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Centimeters",
                        style: TextStyle(
                          color: !showInches ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Table based on toggle
            showInches ? _buildInchesTable() : _buildCentimetersTable(),
            const SizedBox(height: 32),
            const Text(
              "Measurement Guide",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1C),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFEEEEEE)),
            const SizedBox(height: 12),
            const Text(
              "Bust",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Measure under your arms at the fullest part of your bust. Be sure to go over your shoulder blades.",
              style: TextStyle(
                color: Color(0xFF999999),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Natural Waist",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Measure around the narrowest part of your waistline with one forefinger between your body and the measuring tape.",
              style: TextStyle(
                color: Color(0xFF999999),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInchesTable() {
    final rows = [
      ["XS", "32", "24–25", "34–35"],
      ["S", "34", "26–27", "36–37"],
      ["M", "36", "28–29", "38–39"],
      ["L", "38–40", "31–33", "41–43"],
      ["XL", "42", "34", "44"],
    ];

    return _buildTable(rows);
  }

  Widget _buildCentimetersTable() {
    final rows = [
      ["XS", "81", "61–63", "86–89"],
      ["S", "86", "66–69", "91–94"],
      ["M", "91", "71–74", "97–99"],
      ["L", "96–102", "79–84", "104–109"],
      ["XL", "107", "86", "112"],
    ];

    return _buildTable(rows);
  }

  Widget _buildTable(List<List<String>> rows) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFECECEC)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(60),
        },
        border: const TableBorder(
          horizontalInside: BorderSide(color: Color(0xFFECECEC), width: 1),
        ),
        children: [
          const TableRow(
            decoration: BoxDecoration(color: Color(0xFFF4F4F4)),
            children: [
              _TableHeaderCell("Size"),
              _TableHeaderCell("Bust"),
              _TableHeaderCell("Waist"),
              _TableHeaderCell("Hips"),
            ],
          ),
          for (final row in rows)
            TableRow(
              children: [
                _TableDataCell(row[0], bold: true),
                _TableDataCell(row[1]),
                _TableDataCell(row[2]),
                _TableDataCell(row[3]),
              ],
            ),
        ],
      ),
    );
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String label;

  const _TableHeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF1C1C1C),
        ),
      ),
    );
  }
}

class _TableDataCell extends StatelessWidget {
  final String text;
  final bool bold;

  const _TableDataCell(this.text, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: bold ? FontWeight.w500 : FontWeight.normal,
          color: const Color(0xFF1C1C1C),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_library/models/product_model.dart';
import 'package:my_library/components/product/product_card.dart';
import 'package:my_library/route/screen_export.dart';
import 'package:my_library/constants.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> with SingleTickerProviderStateMixin {
  List<String> selectedCategories = [];
  List<String> selectedAuthors = [];

  // Animation for toggle
  late AnimationController _animationController;
  bool isCategorySelected = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Fetch all categories
  Future<List<String>> fetchAllCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection("products").get();
    final allCategories = <String>{};
    for (var doc in snapshot.docs) {
      final List<String> categories = List<String>.from(doc['categories'] ?? []);
      allCategories.addAll(categories);
    }
    return allCategories.toList();
  }

  // Fetch all authors
  Future<List<String>> fetchAllAuthors() async {
    final snapshot = await FirebaseFirestore.instance.collection("products").get();
    final allAuthors = <String>{};
    for (var doc in snapshot.docs) {
      final String author = doc['authorName'] ?? '';
      if (author.isNotEmpty) allAuthors.add(author);
    }
    return allAuthors.toList();
  }

  // Firestore query
  Query<Map<String, dynamic>> productQuery() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection("products");

    if (selectedCategories.isNotEmpty) {
      query = query.where("categories", arrayContainsAny: selectedCategories);
    }

    if (selectedAuthors.isNotEmpty) {
      query = query.where("authorName",
          whereIn: selectedAuthors.length > 10
              ? selectedAuthors.sublist(0, 10)
              : selectedAuthors);
    }

    return query;
  }

  // Bottom sheet for filter
  void showFilterBottomSheet(String type) async {
    final items = type == 'Category' ? await fetchAllCategories() : await fetchAllAuthors();
    final selectedItems = type == 'Category' ? selectedCategories : selectedAuthors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: whiteColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(defaultBorderRadious))),
      builder: (context) {
        final tempSelected = List<String>.from(selectedItems);
        return StatefulBuilder(
          builder: (context, setStateBottom) {
            return Container(
              padding: EdgeInsets.all(defaultPadding),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select $type",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: blackColor),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isSelected = tempSelected.contains(item);
                        return ListTile(
                          title: Text(item),
                          trailing: isSelected
                              ? Icon(Icons.check, color: primaryColor)
                              : null,
                          onTap: () {
                            setStateBottom(() {
                              if (isSelected) {
                                tempSelected.remove(item);
                              } else {
                                tempSelected.add(item);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel",
                            style: TextStyle(color: blackColor80)),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (type == 'Category') {
                              selectedCategories = tempSelected;
                            } else {
                              selectedAuthors = tempSelected;
                            }
                          });
                          Navigator.pop(context);
                        },
                        child: Text("Apply",
                            style: TextStyle(color: primaryColor)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Filter chips
  Widget buildFilterChips() {
    final allFilters = [
      ...selectedCategories.map((c) => {'type': 'Category', 'value': c}),
      ...selectedAuthors.map((a) => {'type': 'Author', 'value': a}),
    ];

    if (allFilters.isEmpty) return SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        ...allFilters.map((f) => Chip(
              label: Text(f['value'] ?? ''),
              backgroundColor: primaryColor.withOpacity(0.2),
              deleteIconColor: primaryColor,
              onDeleted: () {
                setState(() {
                  if (f['type'] == 'Category') {
                    selectedCategories.remove(f['value']);
                  } else {
                    selectedAuthors.remove(f['value']);
                  }
                });
              },
            )),
        ActionChip(
          label: Text("Clear All"),
          onPressed: () {
            setState(() {
              selectedCategories.clear();
              selectedAuthors.clear();
            });
          },
          backgroundColor: errorColor.withOpacity(0.2),
          labelStyle: TextStyle(color: errorColor),
        )
      ],
    );
  }

  // Product list
  Widget buildProductList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: productQuery().snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        final products = snapshot.data!.docs
            .map((doc) => ProductModel.fromFirestore(doc))
            .toList();

        if (products.isEmpty) return Center(child: Text("No products found"));

        return GridView.builder(
          padding: EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              image: product.images.isNotEmpty ? product.images[0] : '',
              authorName: product.authorName,
              title: product.title,
              price: product.price,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(productId: product.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Animated top toggle
  Widget buildTopToggle() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedContainer(
        duration: defaultDuration,
        height: 48,
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(defaultBorderRadious),
          border: Border.all(color: primaryColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isCategorySelected = true;
                    _animationController.forward();
                  });
                  showFilterBottomSheet('Category');
                },
                child: AnimatedContainer(
                  duration: defaultDuration,
                  decoration: BoxDecoration(
                    color: isCategorySelected ? primaryColor : whiteColor,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(defaultBorderRadious),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Categories",
                    style: TextStyle(
                      color: isCategorySelected ? whiteColor : primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isCategorySelected = false;
                    _animationController.reverse();
                  });
                  showFilterBottomSheet('Author');
                },
                child: AnimatedContainer(
                  duration: defaultDuration,
                  decoration: BoxDecoration(
                    color: !isCategorySelected ? primaryColor : whiteColor,
                    borderRadius: BorderRadius.horizontal(
                      right: Radius.circular(defaultBorderRadious),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Authors",
                    style: TextStyle(
                      color: !isCategorySelected ? whiteColor : primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text("Discover Books",
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          buildTopToggle(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: buildFilterChips(),
          ),
          Expanded(child: buildProductList()),
        ],
      ),
    );
  }
}

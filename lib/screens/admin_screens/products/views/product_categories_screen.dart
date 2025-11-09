import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/../../constants.dart';

class AdminProductCategoriesScreen extends StatefulWidget {
  const AdminProductCategoriesScreen({super.key});

  @override
  State<AdminProductCategoriesScreen> createState() =>
      _AdminProductCategoriesScreenState();
}

class _AdminProductCategoriesScreenState
    extends State<AdminProductCategoriesScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedType = "main"; // "main" or "special"
  bool _loading = false;
  String? _editingCategoryId;

  /// Normalize name into slug (remove spaces)
  String _toSlug(String name) {
    return name.replaceAll(RegExp(r'\s+'), '');

  }

  /// Add or Update
  Future<void> _saveCategory() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _loading = true);

    final name = _nameController.text.trim();
    final slug = _toSlug(name);

    if (_editingCategoryId == null) {
      // Add new
      await FirebaseFirestore.instance.collection("categories").add({
        "name": name,
        "slug": slug,
        "type": _selectedType,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } else {
      // Update existing
      await FirebaseFirestore.instance
          .collection("categories")
          .doc(_editingCategoryId)
          .update({
        "name": name,
        "slug": slug,
        "type": _selectedType,
      });
    }

    _nameController.clear();
    _editingCategoryId = null;
    setState(() => _loading = false);
    if (mounted) Navigator.pop(context);
  }

  void _showCategoryDialog({String? id, String? currentName}) {
    if (id != null) {
      _editingCategoryId = id;
      _nameController.text = currentName ?? "";
    } else {
      _editingCategoryId = null;
      _nameController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(defaultBorderRadious)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: defaultPadding,
          right: defaultPadding,
          top: defaultPadding,
          bottom: MediaQuery.of(context).viewInsets.bottom + defaultPadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 60,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: blackColor20,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Text(
              _editingCategoryId == null ? "Add New Category" : "Edit Category",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Category name",
                filled: true,
                fillColor: lightGreyColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: blackColor20),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(defaultBorderRadious),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel",
                        style: TextStyle(color: blackColor)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(defaultBorderRadious),
                      ),
                    ),
                    onPressed: _loading ? null : _saveCategory,
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: whiteColor,
                            ),
                          )
                        : Text(_editingCategoryId == null ? "Add" : "Save"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Confirm delete with bottom sheet
  Future<void> _confirmDeleteCategory(String id, String name) async {
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(defaultBorderRadious)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 60,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: blackColor20,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const Text(
              "Delete Category",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Are you sure you want to delete \"$name\"?",
              textAlign: TextAlign.center,
              style: const TextStyle(color: blackColor80, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: blackColor20),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(defaultBorderRadious),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text("Cancel",
                        style: TextStyle(color: blackColor)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: errorColor,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(defaultBorderRadious),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text("Delete",
                        style: TextStyle(color: whiteColor)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      await _deleteCategory(id);
    }
  }

  Future<void> _deleteCategory(String id) async {
    await FirebaseFirestore.instance.collection("categories").doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyColor,
      appBar: AppBar(
        title: const Text(
          "Manage Categories",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: blackColor,
          ),
        ),
        backgroundColor: whiteColor,
        elevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(defaultBorderRadious),
              constraints: const BoxConstraints(minHeight: 40, minWidth: 160),
              fillColor: primaryColor,
              selectedColor: whiteColor,
              color: blackColor80,
              isSelected: [_selectedType == "main", _selectedType == "special"],
              onPressed: (index) {
                setState(() {
                  _selectedType = index == 0 ? "main" : "special";
                });
              },
              children: const [
                Text("Main Categories"),
                Text("Special Categories"),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: whiteColor),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("categories")
            .where("type", isEqualTo: _selectedType)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Error loading categories:\n${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: errorColor),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No categories found",
                style: TextStyle(color: blackColor60),
              ),
            );
          }

          final docs = snapshot.data!.docs.toList();
          docs.sort((a, b) {
            final ta = a.data()["createdAt"] as Timestamp?;
            final tb = b.data()["createdAt"] as Timestamp?;
            if (ta == null && tb == null) return 0;
            if (ta == null) return 1;
            if (tb == null) return -1;
            return tb.compareTo(ta);
          });

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            padding: const EdgeInsets.all(defaultPadding),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.category, color: primaryColor),
                  ),
                  title: Text(
                    data["name"] ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: blackColor,
                    ),
                  ),
                  subtitle: Text(
                    "${data["type"] ?? ""} • ${data["slug"] ?? ""}",
                    style:
                        const TextStyle(color: blackColor60, fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: primaryColor),
                        onPressed: () => _showCategoryDialog(
                            id: doc.id, currentName: data["name"]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: errorColor),
                        onPressed: () => _confirmDeleteCategory(
                            doc.id, data["name"] ?? "this category"),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

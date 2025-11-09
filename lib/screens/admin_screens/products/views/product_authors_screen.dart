import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../constants.dart';

class AdminAuthorManagementScreen extends StatefulWidget {
  const AdminAuthorManagementScreen({super.key});

  @override
  State<AdminAuthorManagementScreen> createState() =>
      _AdminAuthorManagementScreenState();
}

class _AdminAuthorManagementScreenState
    extends State<AdminAuthorManagementScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _loading = false;
  String? _editingAuthorId;

  /// Add or Update Author
  Future<void> _saveAuthor() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _loading = true);

    if (_editingAuthorId == null) {
      // Add new
      await FirebaseFirestore.instance.collection("authors").add({
        "name": _nameController.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });
    } else {
      // Update existing
      await FirebaseFirestore.instance
          .collection("authors")
          .doc(_editingAuthorId)
          .update({
        "name": _nameController.text.trim(),
      });
    }

    _nameController.clear();
    _editingAuthorId = null;
    setState(() => _loading = false);
    if (mounted) Navigator.pop(context);
  }

  /// Show Add/Edit Bottom Sheet
  void _showAuthorDialog({String? id, String? currentName}) {
    if (id != null) {
      _editingAuthorId = id;
      _nameController.text = currentName ?? "";
    } else {
      _editingAuthorId = null;
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
              _editingAuthorId == null ? "Add New Author" : "Edit Author",
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
                hintText: "Author name",
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
                    onPressed: _loading ? null : _saveAuthor,
                    child: _loading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: whiteColor,
                            ),
                          )
                        : Text(_editingAuthorId == null ? "Add" : "Save"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  /// Delete Confirmation Bottom Sheet
  Future<void> _confirmDeleteAuthor(String id, String name) async {
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
              "Delete Author",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: blackColor),
            ),
            const SizedBox(height: 12),
            Text(
              "Are you sure you want to delete \"$name\"?",
              style: const TextStyle(color: blackColor80, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: blackColor20),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(defaultBorderRadious),
                      ),
                    ),
                    child: const Text("Cancel",
                        style: TextStyle(color: blackColor)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: errorColor,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(defaultBorderRadious),
                      ),
                    ),
                    child: const Text("Delete",
                        style: TextStyle(color: whiteColor)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection("authors").doc(id).delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreyColor,
      appBar: AppBar(
        title: const Text(
          "Manage Authors",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: blackColor,
          ),
        ),
        backgroundColor: whiteColor,
        elevation: 1,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAuthorDialog(),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: whiteColor),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("authors")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Error loading authors:\n${snapshot.error}",
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
                "No authors found",
                style: TextStyle(color: blackColor60),
              ),
            );
          }

          final docs = snapshot.data!.docs;

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
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.person, color: primaryColor),
                  ),
                  title: Text(
                    data["name"] ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: blackColor,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: primaryColor),
                        onPressed: () => _showAuthorDialog(
                            id: doc.id, currentName: data["name"]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: errorColor),
                        onPressed: () =>
                            _confirmDeleteAuthor(doc.id, data["name"] ?? "author"),
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

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'package:my_library/constants.dart';
import 'package:my_library/components/custom_dialog.dart';

class AdminProductAddEditScreen extends StatefulWidget {
  final String? productId; // null => add, not null => edit
  final Map<String, dynamic>? productData;

  const AdminProductAddEditScreen(
      {super.key, this.productId, this.productData});

  @override
  State<AdminProductAddEditScreen> createState() =>
      _AdminProductAddEditScreenState();
}

class _AdminProductAddEditScreenState extends State<AdminProductAddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPercentController = TextEditingController();
  final _discountPriceController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  final List<Uint8List> _imageBytes = [];
  List<String> _uploadedUrls = [];

  List<String> _allMainCategories = [];
  List<String> _allSpecialCategories = [];
  List<String> _selectedMainCategories = [];
  List<String> _selectedSpecialCategories = [];

  List<_AuthorOption> _allAuthors = [];
  String? _selectedAuthorId;
  String? _selectedAuthorName;

  bool _loading = false;
  bool _inStock = true;

  @override
  void initState() {
    super.initState();

    // hydrate from incoming productData
    if (widget.productData != null) {
      final data = widget.productData!;
      _titleController.text = data['title'] ?? '';
      _descController.text = data['description'] ?? '';
      _priceController.text = (data['price'] ?? '').toString();
      _discountPriceController.text =
          (data['priceAfterDiscount'] ?? '').toString();
      _discountPercentController.text =
          (data['discountPercent'] ?? '').toString();

      _uploadedUrls =
          (data['images'] as List?)?.map((e) => e.toString()).toList() ?? [];
      _inStock = data['inStock'] ?? true;

      _selectedMainCategories = List<String>.from(data['categories'] ?? []);
      _selectedSpecialCategories = List<String>.from(
        data['specialCategories'] ?? data['tags'] ?? [],
      );

      _selectedAuthorId = data['authorId'];
      _selectedAuthorName = data['authorName'];
    }

    _discountPercentController.addListener(_updateDiscountPrice);
    _priceController.addListener(_updateDiscountPrice);

    _loadCategories();
    _loadAuthors();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _discountPercentController.dispose();
    _discountPriceController.dispose();
    super.dispose();
  }

  // ------------------------------
  // HELPERS: slug generation & uniqueness
  // ------------------------------
  String _toSlug(String name) {
    // canonical slug: lowercase, spaces -> '-', keep a-z0-9 and hyphen
    var s = name.trim().toLowerCase();
    s = s.replaceAll(RegExp(r'\s+'), '-');
    s = s.replaceAll(RegExp(r'[^a-z0-9\-]'), '');
    // collapse multiple hyphens
    s = s.replaceAll(RegExp(r'-{2,}'), '-');
    if (s.isEmpty) s = DateTime.now().millisecondsSinceEpoch.toString();
    return s;
  }

  /// ensures slug is unique in `categories` collection by appending `-2`, `-3`, ...
  Future<String> _generateUniqueSlug(String name) async {
    final base = _toSlug(name);
    var slug = base;
    final col = FirebaseFirestore.instance.collection('categories');

    int attempt = 1;
    while (true) {
      final q = await col.where('slug', isEqualTo: slug).limit(1).get();
      if (q.docs.isEmpty) return slug;
      attempt++;
      slug = '$base-$attempt';
      // defensive: avoid infinite loop (very unlikely)
      if (attempt > 1000) {
        // fallback to timestamp
        return '$base-${DateTime.now().millisecondsSinceEpoch}';
      }
    }
  }

  // ------------------------------
  // LOADERS
  // ------------------------------
  Future<void> _loadCategories() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection("categories").get();
      final main = <String>[];
      final special = <String>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final name = (data['name'] ?? '').toString();
        final type = (data['type'] ?? 'main').toString();
        if (name.isEmpty) continue;
        if (type == 'special') {
          special.add(name);
        } else {
          main.add(name);
        }
      }

      setState(() {
        _allMainCategories = main.toSet().toList();
        _allSpecialCategories = special.toSet().toList();

        // ensure preselected still visible
        for (final s in _selectedMainCategories) {
          if (!_allMainCategories.contains(s)) _allMainCategories.add(s);
        }
        for (final s in _selectedSpecialCategories) {
          if (!_allSpecialCategories.contains(s)) _allSpecialCategories.add(s);
        }
      });
    } catch (_) {
      // ignore
    }
  }

  Future<void> _loadAuthors() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("authors")
          .orderBy("name")
          .get();

      final loaded = snapshot.docs
          .map((d) {
            final data = d.data();
            return _AuthorOption(
                id: d.id, name: (data['name'] ?? '').toString());
          })
          .where((b) => b.name.isNotEmpty)
          .toList();

      if (_selectedAuthorId == null && _selectedAuthorName != null) {
        final match = loaded.firstWhere(
          (b) => b.name.toLowerCase() == _selectedAuthorName!.toLowerCase(),
          orElse: () => _AuthorOption.empty(),
        );
        if (!match.isEmpty) {
          _selectedAuthorId = match.id;
          _selectedAuthorName = match.name;
        }
      }

      setState(() {
        _allAuthors = loaded;

        if (_selectedAuthorId == null &&
            (_selectedAuthorName?.isNotEmpty ?? false)) {
          _allAuthors = [
            ..._allAuthors,
            _AuthorOption(id: '_custom_', name: _selectedAuthorName!)
          ];
        }
      });
    } catch (_) {
      // ignore
    }
  }

  // ------------------------------
  // IMAGE PICK
  // ------------------------------
  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      final bytesList = await Future.wait(picked.map((e) => e.readAsBytes()));
      setState(() {
        _selectedImages.addAll(picked);
        _imageBytes.addAll(bytesList);
      });
    }
  }

  // ------------------------------
  // PRICING
  // ------------------------------
  void _updateDiscountPrice() {
    final price = double.tryParse(_priceController.text) ?? 0;
    final discount = double.tryParse(_discountPercentController.text) ?? 0;
    final discountedPrice =
        (discount > 0) ? price - (price * discount / 100) : price;
    _discountPriceController.text = discountedPrice.toStringAsFixed(2);
  }

  // ------------------------------
  // CLOUDINARY UPLOAD
  // ------------------------------
  Future<String?> _uploadImageToCloudinary(XFile img) async {
    const cloudName = "dflrecddn";
    const uploadPreset = "Ecommerce";
    final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/upload");

    final req = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset;

    final filename = path.basename(img.path);
    final bytes = await img.readAsBytes();
    req.files
        .add(http.MultipartFile.fromBytes('file', bytes, filename: filename));

    final res = await req.send();
    if (res.statusCode == 200) {
      final body = await res.stream.bytesToString();
      final jsonMap = jsonDecode(body) as Map<String, dynamic>;
      return jsonMap['secure_url']?.toString();
    }
    return null;
  }

  // ------------------------------
  // SAVE
  // ------------------------------
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final finalUrls = <String>[..._uploadedUrls];
      if (_selectedImages.isNotEmpty) {
        final uploads =
            await Future.wait(_selectedImages.map(_uploadImageToCloudinary));
        finalUrls.addAll(uploads.whereType<String>());
      }

      final price = double.tryParse(_priceController.text) ?? 0.0;
      final discountPercent = int.tryParse(_discountPercentController.text);
      final priceAfterDiscount = double.tryParse(_discountPriceController.text);

      if (_selectedAuthorId != null) {
        final pick = _allAuthors.firstWhere(
          (b) => b.id == _selectedAuthorId,
          orElse: () => _AuthorOption(
              id: _selectedAuthorId!, name: _selectedAuthorName ?? ''),
        );
        _selectedAuthorName = pick.name;
      }

      final data = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        'price': price,
        'discountPercent': discountPercent,
        'priceAfterDiscount': priceAfterDiscount,
        'categories': _selectedMainCategories,
        'specialCategories': _selectedSpecialCategories
            .map((cat) => cat.replaceAll(RegExp(r'\s+'), ''))
            .toList(),
        'inStock': _inStock,
        'images': finalUrls,
        'authorId': _selectedAuthorId,
        'authorName': _selectedAuthorName,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final col = FirebaseFirestore.instance.collection('products');

      if (widget.productId == null) {
        await col.add({
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (!mounted) return;
        CustomDialog.show(context,
            message: "Product added successfully", isError: false);
      } else {
        await col.doc(widget.productId!).update(data);
        if (!mounted) return;
        CustomDialog.show(context,
            message: "Product updated successfully", isError: false);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      CustomDialog.show(context,
          message: "Something went wrong", isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ------------------------------
  // AUTHOR: Add / Edit / Delete (bottom sheets)
  // ------------------------------
  Future<void> _showAddAuthorBottomSheet() async {
    final controller = TextEditingController();
    bool loading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateSheet) {
          return Container(
            decoration: const BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(color: blackColor20, blurRadius: 12)],
            ),
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
                    height: 4,
                    width: 60,
                    decoration: BoxDecoration(
                        color: blackColor10,
                        borderRadius: BorderRadius.circular(3))),
                const SizedBox(height: 10),
                const Text("Add New Author",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: blackColor)),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Author name",
                    filled: true,
                    fillColor: lightGreyColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: blackColor20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    defaultBorderRadious))),
                        child: const Text("Cancel",
                            style: TextStyle(color: blackColor)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: loading
                            ? null
                            : () async {
                                final name = controller.text.trim();
                                if (name.isEmpty) return;
                                setStateSheet(() => loading = true);
                                try {
                                  final doc = await FirebaseFirestore.instance
                                      .collection("authors")
                                      .add({
                                    "name": name,
                                    "createdAt": FieldValue.serverTimestamp(),
                                  });
                                  // add locally and select it
                                  setState(() {
                                    _allAuthors.insert(0,
                                        _AuthorOption(id: doc.id, name: name));
                                    _selectedAuthorId = doc.id;
                                    _selectedAuthorName = name;
                                  });
                                } catch (_) {
                                  // ignore
                                } finally {
                                  setStateSheet(() => loading = false);
                                  if (context.mounted) Navigator.pop(ctx);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor),
                        child: loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: whiteColor))
                            : const Text("Add"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _showEditAuthorBottomSheet(_AuthorOption author) async {
    final controller = TextEditingController(text: author.name);
    bool loading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateSheet) {
          return Container(
            decoration: const BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(color: blackColor20, blurRadius: 12)],
            ),
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
                    height: 4,
                    width: 60,
                    decoration: BoxDecoration(
                        color: blackColor10,
                        borderRadius: BorderRadius.circular(3))),
                const SizedBox(height: 10),
                const Text("Edit Author",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: blackColor)),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Author name",
                    filled: true,
                    fillColor: lightGreyColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: blackColor20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    defaultBorderRadious))),
                        child: const Text("Cancel",
                            style: TextStyle(color: blackColor)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: loading
                            ? null
                            : () async {
                                final name = controller.text.trim();
                                if (name.isEmpty) return;
                                setStateSheet(() => loading = true);
                                try {
                                  await FirebaseFirestore.instance
                                      .collection("authors")
                                      .doc(author.id)
                                      .update({"name": name});
                                  // update local list
                                  setState(() {
                                    final idx = _allAuthors
                                        .indexWhere((b) => b.id == author.id);
                                    if (idx >= 0) {
                                      _allAuthors[idx] = _AuthorOption(
                                          id: author.id, name: name);
                                    }
                                    if (_selectedAuthorId == author.id) {
                                      _selectedAuthorName = name;
                                    }
                                  });
                                } catch (_) {
                                  // ignore
                                } finally {
                                  setStateSheet(() => loading = false);
                                  if (context.mounted) Navigator.pop(ctx);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor),
                        child: loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: whiteColor))
                            : const Text("Save"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> _confirmDeleteAuthor(_AuthorOption author) async {
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
                    borderRadius: BorderRadius.circular(3))),
            const Text("Delete Author",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: blackColor)),
            const SizedBox(height: 12),
            Text("Are you sure you want to delete \"${author.name}\"?",
                style: const TextStyle(color: blackColor80, fontSize: 14),
                textAlign: TextAlign.center),
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
                                BorderRadius.circular(defaultBorderRadious))),
                    child: const Text("Cancel",
                        style: TextStyle(color: blackColor)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: errorColor),
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
      try {
        await FirebaseFirestore.instance
            .collection("authors")
            .doc(author.id)
            .delete();
        setState(() {
          _allAuthors.removeWhere((b) => b.id == author.id);
          if (_selectedAuthorId == author.id) {
            _selectedAuthorId = null;
            _selectedAuthorName = null;
          }
        });
      } catch (e) {
        if (mounted) {
          CustomDialog.show(context, message: "Delete Failed", isError: true);
        }
      }
    }
  }

  // Convenience: on long-press of a author chip show actions
  void _showAuthorActions(_AuthorOption author) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(defaultBorderRadious))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              height: 5,
              width: 60,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                  color: blackColor20, borderRadius: BorderRadius.circular(3))),
          ListTile(
            leading: const Icon(Icons.edit, color: primaryColor),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(ctx);
              _showEditAuthorBottomSheet(author);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: errorColor),
            title: const Text('Delete'),
            onTap: () {
              Navigator.pop(ctx);
              _confirmDeleteAuthor(author);
            },
          ),
        ]),
      ),
    );
  }

  // ------------------------------
  // CATEGORY: Add via bottom sheet (new) - updated to save slug & ensure uniqueness
  // ------------------------------
  Future<void> _showAddCategoryBottomSheet() async {
    final controller = TextEditingController();
    String selectedType = 'main';
    bool loading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateSheet) {
          return Container(
            decoration: const BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(color: blackColor20, blurRadius: 12)],
            ),
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
                    height: 4,
                    width: 60,
                    decoration: BoxDecoration(
                        color: blackColor10,
                        borderRadius: BorderRadius.circular(3))),
                const SizedBox(height: 10),
                const Text("Add Category",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: blackColor)),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: "Category name",
                    filled: true,
                    fillColor: lightGreyColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                ToggleButtons(
                  isSelected: [
                    selectedType == 'main',
                    selectedType == 'special'
                  ],
                  onPressed: (index) {
                    setStateSheet(() {
                      selectedType = index == 0 ? 'main' : 'special';
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  selectedBorderColor: primaryColor,
                  children: const [
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Main')),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('Special')),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: blackColor20),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    defaultBorderRadious))),
                        child: const Text("Cancel",
                            style: TextStyle(color: blackColor)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: loading
                            ? null
                            : () async {
                                final name = controller.text.trim();
                                if (name.isEmpty) return;
                                setStateSheet(() => loading = true);
                                try {
                                  // generate unique slug and include it in stored doc
                                  final slug = await _generateUniqueSlug(name);

                                  await FirebaseFirestore.instance
                                      .collection("categories")
                                      .add({
                                    "name": name,
                                    "slug": slug, // <- saved slug
                                    "type": selectedType,
                                    "createdAt": FieldValue.serverTimestamp(),
                                  });

                                  setState(() {
                                    if (selectedType == 'main') {
                                      if (!_allMainCategories.contains(name))
                                        _allMainCategories.insert(0, name);
                                      if (!_selectedMainCategories
                                          .contains(name))
                                        _selectedMainCategories.add(name);
                                    } else {
                                      if (!_allSpecialCategories.contains(name))
                                        _allSpecialCategories.insert(0, name);
                                      if (!_selectedSpecialCategories
                                          .contains(name))
                                        _selectedSpecialCategories.add(name);
                                    }
                                  });
                                } catch (_) {
                                  // ignore
                                } finally {
                                  setStateSheet(() => loading = false);
                                  if (context.mounted) Navigator.pop(ctx);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor),
                        child: loading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: whiteColor))
                            : const Text("Add"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        });
      },
    );
  }

  // ------------------------------
  // UI
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productId != null;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: lightGreyColor,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: true,
            titleSpacing: 0,
            title: Row(
              children: [
                const SizedBox(width: 8),
                Text(isEdit ? "Edit Product" : "Add Product",
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: blackColor80)),
              ],
            ),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  primaryMaterialColor.shade200,
                  primaryMaterialColor.shade500
                ]),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18)),
              ),
            ),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18))),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // IMAGES
                      _ModernImagesGrid(
                        imageBytes: _imageBytes,
                        uploadedUrls: _uploadedUrls,
                        onAddTap: _pickImages,
                        onRemovePicked: (i) => setState(() {
                          _imageBytes.removeAt(i);
                          _selectedImages.removeAt(i);
                        }),
                        onRemoveUploaded: (i) =>
                            setState(() => _uploadedUrls.removeAt(i)),
                      ),

                      const SizedBox(height: defaultPadding),

                      // CORE FIELDS
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(defaultBorderRadious)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(defaultPadding),
                          child: Column(children: [
                            _buildTextField(
                              controller: _titleController,
                              label: "Product Title",
                              icon: Icons.title,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? "Enter product title"
                                  : null,
                            ),
                            _buildTextField(
                                controller: _descController,
                                label: "Description",
                                icon: Icons.description,
                                maxLines: 3),
                            const SizedBox(height: 4),
                            Row(children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _priceController,
                                  label: "Price",
                                  icon: Icons.attach_money,
                                  keyboardType: TextInputType.number,
                                  validator: (v) =>
                                      (v == null || v.trim().isEmpty)
                                          ? "Enter price"
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _discountPercentController,
                                  label: "Discount %",
                                  icon: Icons.percent,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ]),
                            _buildTextField(
                                controller: _discountPriceController,
                                label: "Price After Discount",
                                icon: Icons.money,
                                keyboardType: TextInputType.number,
                                readOnly: true),
                          ]),
                        ),
                      ),

                      const SizedBox(height: defaultPadding),

                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(defaultBorderRadious)),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(defaultPadding),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(
                                      child: Text("Author",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ))),
                                  const SizedBox(width: 8),
                                  // Add chip button
                                  GestureDetector(
                                    onTap: _showAddAuthorBottomSheet,
                                    child: Chip(
                                        avatar: const Icon(Icons.add, size: 18),
                                        label: const Text('Add'),
                                        backgroundColor:
                                            primaryColor.withOpacity(0.1)),
                                  ),
                                ]),
                                const SizedBox(height: 12),
                                if (_allAuthors.isEmpty)
                                  const Text(
                                      "No authors available. Tap Add or Manage Author to add.",
                                      style: TextStyle(color: blackColor60))
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _allAuthors.map((b) {
                                      final isSelected =
                                          b.id == _selectedAuthorId ||
                                              (_selectedAuthorId == null &&
                                                  _selectedAuthorName != null &&
                                                  b.name.toLowerCase() ==
                                                      _selectedAuthorName!
                                                          .toLowerCase());

                                      return GestureDetector(
                                        onLongPress: () =>
                                            _showAuthorActions(b),
                                        child: FilterChip(
                                          label: Text(b.name),
                                          selected: isSelected,
                                          selectedColor:
                                              primaryColor.withOpacity(0.12),
                                          checkmarkColor: primaryColor,
                                          showCheckmark: isSelected,
                                          onSelected: (_) {
                                            setState(() {
                                              // SINGLE SELECT: toggle on tap; tap again to clear
                                              if (isSelected) {
                                                _selectedAuthorId = null;
                                                _selectedAuthorName = null;
                                              } else {
                                                _selectedAuthorId = b.id;
                                                _selectedAuthorName = b.name;
                                              }
                                            });
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),
                              ]),
                        ),
                      ),

                      const SizedBox(height: defaultPadding),

                      // CATEGORIES
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(defaultBorderRadious)),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(defaultPadding),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Main Categories",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                      GestureDetector(
                                        onTap:
                                            _showAddCategoryBottomSheet, // <-- uses bottom sheet now
                                        child: Chip(
                                            avatar:
                                                const Icon(Icons.add, size: 18),
                                            label: const Text('Add'),
                                            backgroundColor:
                                                primaryColor.withOpacity(0.1)),
                                      ),
                                    ]),
                                const SizedBox(height: 8),
                                _buildCategoryWrap(
                                    allCategories: _allMainCategories,
                                    selected: _selectedMainCategories,
                                    onToggle: (cat, selected) {
                                      setState(() {
                                        if (selected) {
                                          if (!_selectedMainCategories
                                              .contains(cat)) {
                                            _selectedMainCategories.add(cat);
                                          }
                                        } else {
                                          _selectedMainCategories.remove(cat);
                                        }
                                      });
                                    }),
                                const SizedBox(height: 12),
                                Text("Special Categories",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).primaryColor)),
                                const SizedBox(height: 8),
                                _buildCategoryWrap(
                                    allCategories: _allSpecialCategories,
                                    selected: _selectedSpecialCategories,
                                    onToggle: (cat, selected) {
                                      setState(() {
                                        if (selected) {
                                          if (!_selectedSpecialCategories
                                              .contains(cat)) {
                                            _selectedSpecialCategories.add(cat);
                                          }
                                        } else {
                                          _selectedSpecialCategories
                                              .remove(cat);
                                        }
                                      });
                                    }),
                              ]),
                        ),
                      ),

                      const SizedBox(height: defaultPadding),

                      SwitchListTile.adaptive(
                          title: const Text("In Stock"),
                          value: _inStock,
                          activeColor: primaryColor,
                          onChanged: (v) => setState(() => _inStock = v)),

                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          icon: Icon(isEdit ? Icons.save : Icons.add),
                          onPressed: _loading ? null : _saveProduct,
                          label:
                              Text(isEdit ? "Update Product" : "Add Product"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      defaultBorderRadious))),
                        ),
                      ),

                      const SizedBox(height: 28),
                    ]),
              ),
            ),
          ),
        ),
        if (_loading)
          Positioned.fill(
            child: Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(child: CircularProgressIndicator())),
          ),
      ],
    );
  }

  // ------------------------------
  // HELPERS (UI)
  // ------------------------------
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor),
          filled: true,
          fillColor: whiteColor,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(defaultBorderRadious),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildCategoryWrap({
    required List<String> allCategories,
    required List<String> selected,
    required void Function(String cat, bool selected) onToggle,
  }) {
    if (allCategories.isEmpty) {
      return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text("No categories available. Tap + to add.",
              style: TextStyle(color: blackColor60)));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allCategories.map((cat) {
        final isSel = selected.contains(cat);
        return FilterChip(
          label: Text(cat),
          selected: isSel,
          selectedColor: primaryColor.withOpacity(0.12),
          checkmarkColor: primaryColor,
          showCheckmark: true,
          onSelected: (sel) => onToggle(cat, sel),
        );
      }).toList(),
    );
  }
}

// ------------------------------
// MODELS / WIDGETS
// ------------------------------
class _AuthorOption {
  final String id;
  final String name;
  const _AuthorOption({required this.id, required this.name});
  static _AuthorOption empty() => const _AuthorOption(id: '', name: '');
  bool get isEmpty => id.isEmpty && name.isEmpty;
}

class _ModernImagesGrid extends StatelessWidget {
  final List<Uint8List> imageBytes;
  final List<String> uploadedUrls;
  final VoidCallback onAddTap;
  final ValueChanged<int> onRemovePicked;
  final ValueChanged<int> onRemoveUploaded;

  const _ModernImagesGrid({
    required this.imageBytes,
    required this.uploadedUrls,
    required this.onAddTap,
    required this.onRemovePicked,
    required this.onRemoveUploaded,
  });

  @override
  Widget build(BuildContext context) {
    final total =
        1 + imageBytes.length + uploadedUrls.length; // +1 for add tile
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadious)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Product Images',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: total,
            itemBuilder: (context, idx) {
              if (idx == 0) {
                return GestureDetector(
                  onTap: onAddTap,
                  child: Container(
                    decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius:
                            BorderRadius.circular(defaultBorderRadious),
                        border: Border.all(color: blackColor20)),
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.12),
                                shape: BoxShape.circle),
                            child: const Icon(Icons.add_a_photo,
                                color: primaryColor, size: 28)),
                        const SizedBox(height: 6),
                        const Text('Add Images',
                            style:
                                TextStyle(color: blackColor60, fontSize: 12)),
                      ]),
                    ),
                  ),
                );
              }

              final index = idx - 1;
              if (index < imageBytes.length) {
                return Stack(fit: StackFit.expand, children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(defaultBorderRadious),
                      child:
                          Image.memory(imageBytes[index], fit: BoxFit.cover)),
                  Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                          onTap: () => onRemovePicked(index),
                          child: const CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close,
                                  color: Colors.white, size: 16)))),
                ]);
              }

              final uploadedIndex = index - imageBytes.length;
              final url = uploadedUrls[uploadedIndex];
              return Stack(fit: StackFit.expand, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  child: Image.network(url, fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2));
                  }),
                ),
                Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                        onTap: () => onRemoveUploaded(uploadedIndex),
                        child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.close,
                                color: Colors.white, size: 16)))),
                Positioned(
                    left: 6,
                    bottom: 6,
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text('Uploaded',
                            style:
                                TextStyle(color: Colors.white, fontSize: 11)))),
              ]);
            },
          ),
        ]),
      ),
    );
  }
}

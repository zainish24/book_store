import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/constants.dart';

class AddNewAddressScreen extends StatelessWidget {
  const AddNewAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();

    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: blackColor),
        title: const Text('Add Address',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: blackColor)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              buildTextField("Full Name", nameController),
              const SizedBox(height: 16),
              buildTextField("Phone Number", phoneController),
              const SizedBox(height: 16),
              buildTextField("Address", addressController, maxLines: 3),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    final addrRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('addresses');

                    final existing = await addrRef.get();
                    final isFirst = existing.docs.isEmpty;

                    await addrRef.add({
                      'label': "My home",
                      'fullName': nameController.text,
                      'address': addressController.text,
                      'phone': phoneController.text,
                      'isDefault': isFirst, // only true for first one
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(defaultBorderRadious))),
                child: const Text("Save Address"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) =>
          value == null || value.isEmpty ? 'This field is required' : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: lightGreyColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadious),
            borderSide: BorderSide.none),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';


class UserModel {
final String id;
final String name;
final String email;
final String? phone;
final String? address;
final String? country;
final String role;
final DateTime createdAt;
final bool isActive;
final String? image;


UserModel({
required this.id,
required this.name,
required this.email,
this.phone,
this.address,
this.country,
required this.role,
required this.createdAt,
this.isActive = true,
this.image,
});


factory UserModel.fromDoc(DocumentSnapshot doc) {
final data = doc.data() as Map<String, dynamic>? ?? {};
return UserModel(
id: doc.id,
name: data['name'] ?? '',
email: data['email'] ?? '',
phone: data['phone'],
address: data['address'],
country: data['country'],
role: data['role'] ?? 'User',
createdAt: (data['created_at'] is Timestamp)
? (data['created_at'] as Timestamp).toDate()
: DateTime.tryParse(data['created_at']?.toString() ?? '') ?? DateTime.now(),
isActive: data['isActive'] ?? true,
image: data['image'],
);
}


Map<String, dynamic> toMap() => {
'name': name,
'email': email,
'phone': phone,
'address': address,
'country': country,
'role': role,
'created_at': createdAt,
'isActive': isActive,
'image': image,
};
}
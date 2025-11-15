class Contact {
  final int? id;
  final int? userId;
  final String name;
  final String phone;
  final String email;
  final String address;

  Contact({
    this.id,
    this.userId,
    required this.name,
    required this.phone,
    required this.email,
    this.address = '',
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Contact.fromMap(Map<String, dynamic> map) => Contact(
        id: map['id'] as int?,
        userId: map['userId'] as int?,
        name: map['name'] ?? '',
        phone: map['phone'] ?? '',
        email: map['email'] ?? '',
        address: map['address'] ?? '',
      );
}

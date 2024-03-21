class Address {
  final String id;
  final String userId;
  final String name;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String country;
  final String postalCode;

  Address({
    required this.id,
    required this.userId,
    required this.name,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
  });



  factory Address.fromMap(Map<String, dynamic> data) {
    return Address(
      id: data['id'],
      userId: data['user_id'],
      name: data['name'],
      addressLine1: data['address_line_1'],
      addressLine2: data['address_line_2'],
      city: data['city'],
      state: data['state'],
      country: data['country'],
      postalCode: data['zip_code'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'country': country,
      'name': name,
      'postalCode': postalCode,
      'state': state,
      'userID': userId,
    };
  }

  Map<String, dynamic> toJson()  {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'zip_code': postalCode,
    };
  }

  static Address fromJson(Map<String, dynamic> data) {
    return Address(
      id: data['id'],
      userId: data['user_id'],
      name: data['name'],
      addressLine1: data['address_line_1'],
      addressLine2: data['address_line_2'],
      city: data['city'],
      state: data['state'],
      country: data['country'],
      postalCode: data['zip_code'],
    );
  }

  String get displayAddress => '$addressLine1, $addressLine2, $city, $state, $postalCode';
}
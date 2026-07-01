class Parent {
  const Parent({
    required this.id,
    required this.fatherName,
    required this.motherName,
    required this.phone,
    required this.address,
  });

  final String id;
  final String fatherName;
  final String motherName;
  final String phone;
  final String address;

  String get displayName {
    final names = [
      fatherName,
      motherName,
    ].where((value) => value.trim().isNotEmpty);
    if (names.isEmpty) {
      return phone.isNotEmpty ? phone : 'Unnamed parent';
    }
    return names.join(' / ');
  }

  factory Parent.fromMap(Map<String, dynamic> data) {
    String firstNonEmptyString(List<String> keys) {
      for (final key in keys) {
        final value = data[key];
        if (value == null) continue;
        final str = value.toString().trim();
        if (str.isNotEmpty) return str;
      }
      return '';
    }

    return Parent(
      id: firstNonEmptyString(['id', 'parent_id', 'parentId']),
      fatherName: firstNonEmptyString(['father_name', 'fatherName']),
      motherName: firstNonEmptyString(['mother_name', 'motherName']),
      phone: firstNonEmptyString(['phone', 'phone_number', 'phoneNumber']),
      address: firstNonEmptyString([
        'address',
        'home_address',
        'addressLine',
        'address_line',
      ]),
    );
  }

  bool matchesSearch(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    return [fatherName, motherName, phone]
        .where((value) => value.isNotEmpty)
        .any((value) => value.toLowerCase().contains(normalizedQuery));
  }
}

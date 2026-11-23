class ClinicOption {
  final String id;
  final String name;
  final String category;
  final String city;
  final String address;
  final String? imageUrl;

  const ClinicOption({
    required this.id,
    required this.name,
    this.category = 'General Healthcare',
    this.city = 'Kochi',
    this.address = '',
    this.imageUrl,
  });
}

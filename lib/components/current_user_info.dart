// lib/components/current_user_info.dart

class CurrentUser {
  final String name;
  final List<String> apartment_id;
  final String phone;

  CurrentUser({
    required this.name,
    required this.apartment_id,
    required this.phone,
  });
}

/// Sample user data.
/// In the future, this will be populated from a service like PocketBase after login.
final currentUserInfo = CurrentUser(
  name: 'Nguyen Van A',
  apartment_id: ['A1-101', 'B2-202'],
  phone: '0987654321',
);

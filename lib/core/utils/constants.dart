class AppConstants {
  static const String usersCollection = 'users';
  static const String servicesCollection = 'services';
  static const String transactionsCollection = 'transactions';
}

enum UserRole {
  admin,
  employee,
}

extension UserRoleExtension on UserRole {
  String get name => toString().split('.').last;
}

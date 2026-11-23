class PlatformUsersFilterOptions {
  final String status;
  final String userType;
  final String queueActivity;
  final String verification;

  const PlatformUsersFilterOptions({
    this.status = 'all',
    this.userType = 'all',
    this.queueActivity = 'all',
    this.verification = 'all',
  });

  bool get isDefault =>
      status == 'all' &&
      userType == 'all' &&
      queueActivity == 'all' &&
      verification == 'all';

  int get activeFiltersCount {
    int count = 0;
    if (status != 'all') count++;
    if (userType != 'all') count++;
    if (queueActivity != 'all') count++;
    if (verification != 'all') count++;
    return count;
  }

  PlatformUsersFilterOptions copyWith({
    String? status,
    String? userType,
    String? queueActivity,
    String? verification,
  }) {
    return PlatformUsersFilterOptions(
      status: status ?? this.status,
      userType: userType ?? this.userType,
      queueActivity: queueActivity ?? this.queueActivity,
      verification: verification ?? this.verification,
    );
  }
}

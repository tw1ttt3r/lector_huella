class User {
  final int id;
  final String fingerprintData;
  final String firstName;
  final String paternalLastName;
  final String maternalLastName;
  final DateTime createdAt;

  User({
    required this.id,
    required this.fingerprintData,
    required this.firstName,
    required this.paternalLastName,
    required this.maternalLastName,
    required this.createdAt,
  });

  String get fullName => '$firstName $paternalLastName $maternalLastName';

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      fingerprintData: map['fingerprint_data'] as String,
      firstName: map['first_name'] as String,
      paternalLastName: map['paternal_last_name'] as String,
      maternalLastName: map['maternal_last_name'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class AccessLog {
  final int id;
  final int? userId;
  final DateTime accessTime;

  AccessLog({required this.id, required this.userId, required this.accessTime});

  factory AccessLog.fromMap(Map<String, dynamic> map) {
    return AccessLog(
      id: map['id'] as int,
      userId: map['user_id'] as int?,
      accessTime: DateTime.parse(map['access_time'] as String),
    );
  }
}

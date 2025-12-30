class UserSession {
  final String email;
  final String role;
  final String tenantId;
  final String? mockJwt;

  UserSession({
    required this.email,
    required this.role,
    required this.tenantId,
    this.mockJwt,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'role': role,
        'tenantId': tenantId,
        'mockJwt': mockJwt,
      };

  factory UserSession.fromJson(Map<String, dynamic> m) => UserSession(
        email: m['email'] as String,
        role: m['role'] as String,
        tenantId: m['tenantId'] as String,
        mockJwt: m['mockJwt'] as String?,
      );
}

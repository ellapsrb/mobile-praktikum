class Course {
  final int? id;
  final int? userId;
  final String code;
  final String title;
  final int credits;
  final String status;
  final String? body;

  Course({
    this.id,
    this.userId,
    required this.code,
    required this.title,
    required this.credits,
    required this.status,
    this.body,
  });

  // Mengubah JSON menjadi objek Course.
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      credits: json['credits'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
      body: json['body'] as String?,
    );
  }

  // Mengubah objek Course menjadi JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'code': code,
      'title': title,
      'credits': credits,
      'status': status,
      'body': body,
    };
  }
}
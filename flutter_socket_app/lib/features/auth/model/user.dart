class User {
  final String id;
  final String lastSeen;
  final String userName;
  final bool online;

  User({
    required this.id,
    required this.lastSeen,
    required this.userName,
    required this.online,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      lastSeen: json['lastSeen'],
      userName: json['userName'],
      online: json['online'],
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'lastSeen': lastSeen,
    'name': userName,
    'online': online,
  };
}

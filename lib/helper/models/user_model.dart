class ChatUser {
  ChatUser({
    required this.isOnline,
    required this.image,
    required this.phone,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.lastActive,
    required this.id,
    required this.email,
    required this.pushToken,
  });
  late bool isOnline;
  late String image;
  late String phone;
  late String about;
  late String name;
  late String createdAt;
  late String lastActive;
  late String id;
  late String email;
  late String pushToken;

  ChatUser.fromJson(Map<String, dynamic> json) {
    isOnline = json['is_Online'] ?? "";
    image = json['image'] ?? "";
    phone = json['phone'] ?? "";
    about = json['about'] ?? "";
    name = json['name'] ?? "";
    createdAt = json['created_at'] ?? "";
    lastActive = json['last_active'] ?? "";
    id = json['id'] ?? "";
    email = json['email'] ?? "";
    pushToken = json['push_token'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['is_Online'] = isOnline;
    data['image'] = image;
    data['phone'] = phone;
    data['about'] = about;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['last_active'] = lastActive;
    data['id'] = id;
    data['email'] = email;
    data['push_token'] = pushToken;
    return data;
  }
}

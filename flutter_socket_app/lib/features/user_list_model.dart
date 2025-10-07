class UserList {
  int? statusCode;
  List<UserData>? data;
  String? message;

  UserList({this.statusCode, this.data, this.message});

  UserList.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    if (json['data'] != null) {
      data = <UserData>[];
      json['data'].forEach((v) {
        data!.add(new UserData.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class UserData {
  bool? online;
  String? sId;
  String? userName;
  String? password;
  String? lastSeen;

  UserData({this.online, this.sId, this.userName, this.password, this.lastSeen});

  UserData.fromJson(Map<String, dynamic> json) {
    online = json['online'];
    sId = json['_id'];
    userName = json['userName'];
    password = json['password'];
    lastSeen = json['lastSeen'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['online'] = online;
    data['_id'] = sId;
    data['userName'] = userName;
    data['password'] = password;
    data['lastSeen'] = lastSeen;

    return data;
  }
}

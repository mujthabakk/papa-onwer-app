class ChatListModel {
  int? id;
  int? senderId;
  int? roomId;
  String? message;
  int? messageType;
  int? reported;
  String? extraFields;
  int? status;
  String? updatedAt;

  ChatListModel(
      {this.id,
      this.senderId,
      this.roomId,
      this.message,
      this.messageType,
      this.reported,
      this.extraFields,
      this.status,
      this.updatedAt});

  ChatListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? int.parse(json['id'].toString()) : null;
    senderId = json['sender_id'] != null ? int.parse(json['sender_id'].toString()) : null;
    roomId = json['room_id'] != null ? int.parse(json['room_id'].toString()) : null;
    message = json['message'];
    messageType = json['message_type'] != null ? int.parse(json['message_type'].toString()) : null;
    reported = json['reported'] != null ? int.parse(json['reported'].toString()) : null;
    extraFields = json['extra_fields'];
    status = json['status'] != null ? int.parse(json['status'].toString()) : null;
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['sender_id'] = senderId;
    data['room_id'] = roomId;
    data['message'] = message;
    data['message_type'] = messageType;
    data['reported'] = reported;
    data['extra_fields'] = extraFields;
    data['status'] = status;
    data['updated_at'] = updatedAt;
    return data;
  }
}

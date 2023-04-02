class NotificationModel {
  int? userId, orderId;
  String? status, createdAt, image, type, title, description, payload;

  NotificationModel(
      {this.userId,
      this.orderId,
      this.status,
      this.createdAt,
      this.image,
      this.type,
      this.title,
      this.description,
      this.payload});

  Map toJson() => {
        'user_id': userId,
        'order_id': orderId,
        'status': status,
        'created_at': createdAt,
        'image': image,
        'type': type,
        'title': title,
        'description': description,
        'payload': payload
      };

  NotificationModel.fromJson(Map json) {
    userId = json['user_id'];
    orderId = json['order_id'];
    status = json['status'];
    createdAt = json['created_at'];
    image = json['image'];
    type = json['type'] ?? 'order';
    title = json['title'];
    description = json['description'];
    payload = json['payload'];
  }
}

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:nyoba/models/notification_model.dart';
import 'package:nyoba/services/notification_api.dart';
import 'package:nyoba/services/session.dart';

class NotificationProvider with ChangeNotifier {
  bool isLoading = false;
  List<NotificationModel> notification = [];

  Future<List?> fetchNotifications({status, search}) async {
    isLoading = !isLoading;
    var result;
    await NotificationAPI().notification().then((data) async {
      result = data;
      notification.clear();

      if (Session.data.containsKey('local_notif')) {
        final List<dynamic> jsonData =
            jsonDecode(Session.data.getString('local_notif') ?? '[]');
        notification = jsonData.map<NotificationModel>((jsonItem) {
          return NotificationModel.fromJson(jsonItem);
        }).toList();
      }

      for (Map item in result) {
        notification.add(NotificationModel.fromJson(item));
      }

      notification.sort((b, a) {
        var adate = DateTime.parse(a.createdAt!);
        var bdate = DateTime.parse(b.createdAt!);
        return adate.compareTo(
            bdate); //to get the order other way just switch `adate & bdate`
      });

      isLoading = !isLoading;
      notifyListeners();
    });
    return result;
  }
}

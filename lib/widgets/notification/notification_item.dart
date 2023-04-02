import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/models/notification_model.dart';
import 'package:nyoba/utils/notification_text.dart';
import 'package:nyoba/utils/utility.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel? notification;
  const NotificationItem({Key? key, this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (notification?.type == 'promo') {
      final DateTime now = DateTime.parse(notification!.createdAt!);
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      final String formatted = formatter.format(now);
      return Column(
        children: [
          CachedNetworkImage(
              imageUrl: notification!.image!,
              width: double.infinity,
              placeholder: (context, url) => Container(),
              errorWidget: (context, url, error) =>
                  Icon(Icons.image_not_supported_outlined)),
          SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(3)),
                              child: Text(
                                "Promo",
                                style: TextStyle(
                                    fontSize: responsiveFont(8),
                                    color: Colors.white),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.query_builder),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  formatted,
                                  style: TextStyle(
                                      fontSize: responsiveFont(8),
                                      fontWeight: FontWeight.w300),
                                )
                              ],
                            ),
                          ],
                        ),
                        Text(
                          notification!.title!,
                          style: TextStyle(
                              fontSize: responsiveFont(10),
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                  text: '${notification!.description!} ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: responsiveFont(9))),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      );
    }
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              width: 80.h,
              height: 80.h,
              child: notification!.image == null
                  ? Icon(
                      Icons.broken_image_outlined,
                      size: 80,
                    )
                  : CachedNetworkImage(
                      imageUrl: notification!.image!,
                      memCacheHeight: 200,
                      memCacheWidth: 200,
                      placeholder: (context, url) => Container(),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.image_not_supported_outlined)),
            ),
            SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(3)),
                        child: Text(
                          "Shopping",
                          style: TextStyle(
                              fontSize: responsiveFont(8), color: Colors.white),
                        ),
                      ),
                      Text(
                        buildNotificationTitle(notification!.status, context),
                        style: TextStyle(
                            fontSize: responsiveFont(10),
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                                text:
                                    '${AppLocalizations.of(context)!.translate('order_with_number')} ',
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: responsiveFont(9))),
                            TextSpan(
                                text: notification!.orderId.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: responsiveFont(9),
                                    color: primaryColor)),
                            TextSpan(
                                text: buildNotificationSubtitle(
                                    notification!.status, context),
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: responsiveFont(9))),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.query_builder),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        notification!.createdAt!,
                        style: TextStyle(
                            fontSize: responsiveFont(8),
                            fontWeight: FontWeight.w300),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        )
      ],
    );
  }
}

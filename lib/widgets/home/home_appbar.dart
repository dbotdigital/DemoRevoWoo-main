import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nyoba/app_localizations.dart';
import 'package:nyoba/pages/home/socmed_screen.dart';
import 'package:nyoba/pages/notification/notification_screen.dart';
import 'package:nyoba/pages/order/my_order_screen.dart';
import 'package:nyoba/pages/search/search_screen.dart';
import 'package:nyoba/pages/wishlist/wishlist_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:provider/provider.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final animatedText =
        Provider.of<HomeProvider>(context, listen: false).searchBarText;
    return Material(
      elevation: 5,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: primaryColor,
        ),
        child: Container(
          height: 65.h,
          padding: EdgeInsets.only(left: 15, right: 10, top: 15, bottom: 15),
          child: Row(
            children: [
              Expanded(
                  flex: 4,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchScreen()));
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        width: 200.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.white),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: primaryColor,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            animatedText.description != null
                                ? DefaultTextStyle(
                                    style: TextStyle(
                                        fontSize: responsiveFont(12),
                                        color: Colors.black45),
                                    child: AnimatedTextKit(
                                      isRepeatingAnimation: true,
                                      repeatForever: true,
                                      animatedTexts: [
                                        TyperAnimatedText(
                                            AppLocalizations.of(context)!
                                                .translate('search')!,
                                            speed: Duration(milliseconds: 80)),
                                        if (animatedText.description['text_1']
                                                .isNotEmpty &&
                                            animatedText.description != null)
                                          TyperAnimatedText(animatedText
                                              .description['text_1']),
                                        if (animatedText.description['text_2']
                                                .isNotEmpty &&
                                            animatedText.description != null)
                                          TyperAnimatedText(animatedText
                                              .description['text_2']),
                                        if (animatedText.description['text_3']
                                                .isNotEmpty &&
                                            animatedText.description != null)
                                          TyperAnimatedText(animatedText
                                              .description['text_3']),
                                        if (animatedText.description['text_4']
                                                .isNotEmpty &&
                                            animatedText.description != null)
                                          TyperAnimatedText(animatedText
                                              .description['text_4']),
                                        if (animatedText.description['text_5']
                                                .isNotEmpty &&
                                            animatedText.description != null)
                                          TyperAnimatedText(animatedText
                                              .description['text_5']),
                                      ],
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SearchScreen()));
                                      },
                                    ),
                                  )
                                : DefaultTextStyle(
                                    style: TextStyle(
                                        fontSize: responsiveFont(12),
                                        color: Colors.black45),
                                    child: AnimatedTextKit(
                                      isRepeatingAnimation: true,
                                      repeatForever: true,
                                      animatedTexts: [
                                        TyperAnimatedText(
                                            AppLocalizations.of(context)!
                                                .translate('search')!,
                                            speed: Duration(milliseconds: 80)),
                                      ],
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SearchScreen()));
                                      },
                                    ),
                                  ),
                          ],
                        )),
                  )),
              Container(
                width: 10.w,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SocmedScreen()));
                    },
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        width: 23.w,
                        child: Image.asset("images/lobby/icon-cs-app-bar.png")),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => WishList()));
                    },
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        width: 27.w,
                        child: Image.asset("images/lobby/heart.png")),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MyOrder()));
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      width: 27.w,
                      child: Image.asset(
                        "images/lobby/document.png",
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotificationScreen()));
                    },
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        width: 27.w,
                        child: Image.asset(
                          "images/lobby/bellRinging.png",
                        )),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:nyoba/models/banner_mini_model.dart';
import 'package:nyoba/pages/blog/blog_detail_screen.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/pages/product/product_detail_screen.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:nyoba/widgets/webview/webview.dart';
import 'package:provider/provider.dart';

class BannerMini extends StatelessWidget {
  final String? typeBanner;
  const BannerMini({Key? key, this.typeBanner}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, value, child) {
      List<BannerMiniModel> _miniBanner = [];
      if (typeBanner == 'love') {
        _miniBanner = value.bannerLove;
      } else if (typeBanner == 'special') {
        _miniBanner = value.bannerSpecial;
      }
      return Container(
        margin: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 15),
        child: GridView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: _miniBanner.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              childAspectRatio: 2 / 1),
          itemBuilder: (context, i) {
            return Container(
              decoration: BoxDecoration(
                  color: primaryColor, borderRadius: BorderRadius.circular(5)),
              child: InkWell(
                  onTap: () {
                    if (_miniBanner[i].linkTo == 'URL') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WebViewScreen(
                            title: _miniBanner[i].titleSlider,
                            url: _miniBanner[i].name,
                          ),
                        ),
                      );
                    }
                    if (_miniBanner[i].linkTo == 'category') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BrandProducts(
                                    categoryId:
                                        _miniBanner[i].product.toString(),
                                    brandName: _miniBanner[i].name,
                                  )));
                    }
                    if (_miniBanner[i].linkTo == 'blog') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlogDetail(
                            id: _miniBanner[i].product.toString(),
                          ),
                        ),
                      );
                    }
                    if (_miniBanner[i].linkTo == 'product') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductDetail(
                                    productId:
                                        _miniBanner[i].product.toString(),
                                  )));
                    }
                    if (_miniBanner[i].linkTo == 'attribute') {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BrandProducts(
                                    categoryId:
                                        _miniBanner[i].product.toString(),
                                    brandName: _miniBanner[i].name,
                                  )));
                    }
                  },
                  child: Image.network(_miniBanner[i].image!)),
            );
          },
        ),
      );
    });
  }
}

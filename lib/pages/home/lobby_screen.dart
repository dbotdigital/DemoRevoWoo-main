/* Dart Package */
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:nyoba/pages/category/brand_product_screen.dart';
import 'package:nyoba/pages/order/coupon_screen.dart';
import 'package:nyoba/pages/product/product_more_screen.dart';
import 'package:nyoba/models/product_model.dart';
import 'package:nyoba/provider/chat_provider.dart';
import 'package:nyoba/provider/coupon_provider.dart';
import 'package:nyoba/provider/home_provider.dart';
import 'package:nyoba/provider/product_provider.dart';
import 'package:nyoba/provider/wallet_provider.dart';
import 'package:nyoba/services/session.dart';
import 'package:nyoba/widgets/home/chat_card.dart';
import 'package:provider/provider.dart';

/* Widget  */
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import '../../app_localizations.dart';
import '../../provider/app_provider.dart';
import '../../widgets/home/categories/badge_category.dart';
import '../../widgets/home/card_item_small.dart';
import '../../widgets/home/grid_item.dart';
import 'package:nyoba/widgets/draggable/draggable_widget.dart';
import 'package:nyoba/widgets/draggable/model/anchor_docker.dart';
import 'package:nyoba/widgets/home/banner/banner_mini.dart';
import 'package:nyoba/widgets/home/banner/banner_pop_image.dart';
import 'package:nyoba/widgets/home/home_header.dart';
import 'package:nyoba/widgets/home/product_container.dart';
import 'package:nyoba/widgets/home/wallet_card.dart';
import 'package:nyoba/widgets/home/flashsale/flash_sale_countdown.dart';
import 'package:nyoba/widgets/product/grid_item_shimmer.dart';

/* Provider */
import '../../provider/category_provider.dart';

/* Helper */
import '../../utils/utility.dart';

class LobbyScreen extends StatefulWidget {
  LobbyScreen({Key? key}) : super(key: key);

  @override
  _LobbyScreenState createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen>
    with TickerProviderStateMixin {
  AnimationController? _colorAnimationController;
  AnimationController? _textAnimationController;
  Animation? _colorTween, _titleColorTween, _iconColorTween, _moveTween;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  int itemCount = 10;
  int itemCategoryCount = 9;
  int? clickIndex = 0;
  int page = 1;
  String? selectedCategory;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    printLog('Init', name: 'Init Home');
    final products = Provider.of<ProductProvider>(context, listen: false);
    final home = Provider.of<HomeProvider>(context, listen: false);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (products.listBestDeal.length % 20 == 0 &&
            !products.loadingBestDeals &&
            products.listBestDeal.isNotEmpty) {
          setState(() {
            page++;
          });
          loadBestDeals();
        }
      }
    });
    _colorAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _colorTween = ColorTween(
      begin: primaryColor.withOpacity(0.0),
      end: primaryColor.withOpacity(1.0),
    ).animate(_colorAnimationController!);
    _titleColorTween = ColorTween(
      begin: Colors.white,
      end: HexColor("ED625E"),
    ).animate(_colorAnimationController!);
    _iconColorTween = ColorTween(begin: Colors.white, end: HexColor("#4A3F35"))
        .animate(_colorAnimationController!);
    _textAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _moveTween = Tween(
      begin: Offset(0, 0),
      end: Offset(-25, 0),
    ).animate(_colorAnimationController!);

    loadHome();

    if (home.isReload) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        refreshHome();
      });
    }

    if (Session.data.getBool('isLogin')!) {
      loadRecentProduct();
      loadWallet();
      loadCoupon();
    }
    loadBestDeals();
    loadUnreadMessage();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  int item = 6;

  loadUnreadMessage() async {
    await Provider.of<ChatProvider>(context, listen: false)
        .checkUnreadMessage();
  }

  loadBestDeals() async {
    await Provider.of<ProductProvider>(context, listen: false)
        .fetchBestDeals(page: page);
  }

  loadNewProduct(bool loading) async {
    this.setState(() {});
    await Provider.of<ProductProvider>(context, listen: false)
        .fetchNewProducts(clickIndex == 0 ? '' : clickIndex.toString());
  }

  loadRecentProduct() async {
    await Provider.of<ProductProvider>(context, listen: false)
        .fetchRecentProducts();
  }

  loadHome() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final home = Provider.of<HomeProvider>(context, listen: false);
      if (home.bannerPopUp.first.image != null &&
          home.bannerPopUp.first.image != "" &&
          home.isBannerPopChanged) {
        await showDialog(context: context, builder: (_) => BannerPopImage())
            .then((value) {
          context.read<HomeProvider>().changePopBannerStatus(false);
          printLog("Close Banner");
        });
      }
    });
    await Provider.of<HomeProvider>(context, listen: false)
        .fetchHomeData(context);
  }

  loadWallet() async {
    if (Session.data.getBool('isLogin')!)
      await Provider.of<WalletProvider>(context, listen: false).fetchBalance();
  }

  refreshHome() async {
    if (mounted) {
      context.read<WalletProvider>().changeWalletStatus();
      loadWallet();
      await Provider.of<HomeProvider>(context, listen: false)
          .fetchHome(context);
      loadNewProduct(true);
      loadUnreadMessage();
      loadCoupon();
      loadBestDeals();
      _refreshController.refreshCompleted();
      await Provider.of<HomeProvider>(context, listen: false).changeIsReload();
    }
  }

  loadRecommendationProduct(include) async {
    await Provider.of<HomeProvider>(context, listen: false)
        .fetchMoreRecommendation(include, page: page)
        .then((value) {
      this.setState(() {});
      Future.delayed(Duration(milliseconds: 3500), () {
        print('Delayed Done');
        this.setState(() {});
      });
    });
  }

  loadCoupon() async {
    await Provider.of<CouponProvider>(context, listen: false)
        .fetchCoupon(page: 1)
        .then((value) => this.setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  final dragController = DragController();

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductProvider>(context, listen: false);
    final home = Provider.of<HomeProvider>(context, listen: false);
    final coupons = Provider.of<CouponProvider>(context, listen: false);

    Widget buildNewProducts = Container(
      child: ListenableProvider.value(
        value: products,
        child: Consumer<ProductProvider>(builder: (context, value, child) {
          if (value.loadingNew) {
            return Container(
                height: MediaQuery.of(context).size.height / 3.0,
                child: shimmerProductItemSmall());
          }
          return ProductContainer(
            products: value.listNewProduct,
          );
        }),
      ),
    );

    Widget buildRecentProducts = Container(
      child: ListenableProvider.value(
        value: products,
        child: Consumer<ProductProvider>(builder: (context, value, child) {
          return Visibility(
              visible: value.listRecentProduct.isNotEmpty,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .translate('recent_view')!,
                          style: TextStyle(
                              fontSize: responsiveFont(14),
                              fontWeight: FontWeight.w600),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProductMoreScreen(
                                          name: AppLocalizations.of(context)!
                                              .translate('recent_view')!,
                                          include: value.productRecent,
                                        )));
                          },
                          child: Text(
                            AppLocalizations.of(context)!.translate('more')!,
                            style: TextStyle(
                                fontSize: responsiveFont(12),
                                fontWeight: FontWeight.w600,
                                color: secondaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ProductContainer(
                    products: value.listRecentProduct,
                  )
                ],
              ));
        }),
      ),
    );

    Widget buildRecommendation = Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 15, top: 15),
            child: Text(
              home.recommendationProducts[0].title! == 'Recommendations For You'
                  ? AppLocalizations.of(context)!.translate('title_hap_3')!
                  : home.recommendationProducts[0].title!,
              style: TextStyle(
                  fontSize: responsiveFont(14), fontWeight: FontWeight.w600),
            ),
          ),
          Container(
              margin: EdgeInsets.only(left: 15, bottom: 10, right: 15),
              child: Text(
                home.recommendationProducts[0].description! ==
                        'Recommendation Products'
                    ? AppLocalizations.of(context)!
                        .translate('description_hap_3')!
                    : home.recommendationProducts[0].description!,
                style: TextStyle(
                  fontSize: responsiveFont(12),
                  color: Colors.black,
                ),
                textAlign: TextAlign.justify,
              )),
          //recommendation item
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: GridView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: home.recommendationProducts[0].products!.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  childAspectRatio: 78 / 125),
              itemBuilder: (context, i) {
                return GridItem(
                  i: i,
                  itemCount: home.recommendationProducts[0].products!.length,
                  product: home.recommendationProducts[0].products![i],
                );
              },
            ),
          ),
        ],
      ),
    );

    return ColorfulSafeArea(
      color: primaryColor,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            SmartRefresher(
              controller: _refreshController,
              scrollController: _scrollController,
              onRefresh: refreshHome,
              child: SingleChildScrollView(
                physics: ScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Home Header (incl. AppBar, Banner Slider, etc)
                    HomeHeader(),
                    //chat
                    ChatCard(),
                    // wallet
                    WalletCard(showBtnMore: true),
                    // ChatCard(),
                    Container(
                      height: 15,
                    ),
                    //category section
                    Consumer<HomeProvider>(builder: (context, value, child) {
                      return BadgeCategory(
                        value.categories,
                      );
                    }),
                    //flash sale countdown & card product item
                    Consumer<HomeProvider>(builder: (context, value, child) {
                      if (value.flashSales.isEmpty) {
                        return Container();
                      }
                      return FlashSaleCountdown(
                        dataFlashSaleCountDown: home.flashSales,
                        dataFlashSaleProducts: home.flashSales[0].products,
                        textAnimationController: _textAnimationController,
                        colorAnimationController: _colorAnimationController,
                        colorTween: _colorTween,
                        iconColorTween: _iconColorTween,
                        moveTween: _moveTween,
                        titleColorTween: _titleColorTween,
                        loading: home.loading,
                      );
                    }),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                          left: 15, bottom: 10, right: 15, top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!
                                .translate('new_product')!,
                            style: TextStyle(
                                fontSize: responsiveFont(14),
                                fontWeight: FontWeight.w600),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BrandProducts(
                                            categoryId: clickIndex == 0
                                                ? ''
                                                : clickIndex.toString(),
                                            brandName: selectedCategory ??
                                                AppLocalizations.of(context)!
                                                    .translate('new_product'),
                                            sortIndex: 1,
                                          )));
                            },
                            child: Text(
                              AppLocalizations.of(context)!.translate('more')!,
                              style: TextStyle(
                                  fontSize: responsiveFont(12),
                                  fontWeight: FontWeight.w600,
                                  color: secondaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Consumer<CategoryProvider>(
                        builder: (context, value, child) {
                      if (value.loading) {
                        return Container(
                          margin: EdgeInsets.only(left: 15),
                          height: MediaQuery.of(context).size.height / 21,
                          child: ListView.separated(
                            itemCount: 6,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, i) {
                              return Shimmer.fromColors(
                                child: Container(
                                  color: Colors.white,
                                  height: 25,
                                  width: 100,
                                ),
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(
                                width: 5,
                              );
                            },
                          ),
                        );
                      } else {
                        return Container(
                          height: MediaQuery.of(context).size.height / 21,
                          child: ListView.separated(
                              itemCount: value.productCategories.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, i) {
                                return GestureDetector(
                                    onTap: () {
                                      if (value.productCategories[i].id ==
                                          clickIndex) {
                                        setState(() {
                                          clickIndex = 0;
                                          selectedCategory =
                                              AppLocalizations.of(context)!
                                                  .translate('new_product');
                                        });
                                      } else {
                                        setState(() {
                                          clickIndex =
                                              value.productCategories[i].id;
                                          selectedCategory =
                                              value.productCategories[i].name;
                                        });
                                      }
                                      loadNewProduct(true);
                                      setState(() {});
                                    },
                                    child: tabCategory(
                                        value.productCategories[i],
                                        i,
                                        value.productCategories.length));
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return SizedBox(
                                  width: 8,
                                );
                              }),
                        );
                      }
                    }),
                    Container(
                      height: 10,
                    ),
                    buildNewProducts,
                    Container(
                      height: 15,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        AppLocalizations.of(context)!.translate('banner_1')!,
                        style: TextStyle(
                            fontSize: responsiveFont(14),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    //Mini Banner Item start Here
                    BannerMini(
                      typeBanner: 'special',
                    ),
                    //special for you item
                    Consumer<HomeProvider>(builder: (context, value, child) {
                      return Column(
                        children: [
                          Container(
                              width: double.infinity,
                              margin: EdgeInsets.only(
                                  left: 15, bottom: 10, right: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                          child: Text(
                                        value.specialProducts[0].title! ==
                                                'Special Promo : App Only'
                                            ? AppLocalizations.of(context)!
                                                .translate('title_hap_1')!
                                            : value.specialProducts[0].title!,
                                        style: TextStyle(
                                            fontSize: responsiveFont(14),
                                            fontWeight: FontWeight.w600),
                                      )),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          ProductMoreScreen(
                                                            include: products
                                                                .productSpecial
                                                                .products,
                                                            name: value
                                                                        .specialProducts[
                                                                            0]
                                                                        .title! ==
                                                                    'Special Promo : App Only'
                                                                ? AppLocalizations.of(
                                                                        context)!
                                                                    .translate(
                                                                        'title_hap_1')!
                                                                : value
                                                                    .specialProducts[
                                                                        0]
                                                                    .title!,
                                                          )));
                                        },
                                        child: Text(
                                          AppLocalizations.of(context)!
                                              .translate('more')!,
                                          style: TextStyle(
                                              fontSize: responsiveFont(12),
                                              fontWeight: FontWeight.w600,
                                              color: secondaryColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    value.specialProducts[0].description == null
                                        ? ''
                                        : value.specialProducts[0]
                                                    .description! ==
                                                'For You'
                                            ? AppLocalizations.of(context)!
                                                .translate('description_hap_1')!
                                            : value.specialProducts[0]
                                                .description!,
                                    style: TextStyle(
                                      fontSize: responsiveFont(12),
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.justify,
                                  )
                                ],
                              )),
                          AspectRatio(
                            aspectRatio: 3 / 2,
                            child: value.loading
                                ? shimmerProductItemSmall()
                                : ListView.separated(
                                    itemCount: value
                                        .specialProducts[0].products!.length,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (context, i) {
                                      return CardItem(
                                        product: value
                                            .specialProducts[0].products![i],
                                        i: i,
                                        itemCount: value.specialProducts[0]
                                            .products!.length,
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return SizedBox(
                                        width: 5,
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    }),
                    Container(
                      height: 10,
                    ),
                    Stack(
                      children: [
                        Container(
                          color: primaryColor,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height / 3.5,
                        ),
                        Consumer<HomeProvider>(
                            builder: (context, value, child) {
                          if (value.loading) {
                            return Column(
                              children: [
                                Shimmer.fromColors(
                                    child: Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.only(
                                          left: 15, right: 15, top: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: 150,
                                                height: 10,
                                                color: Colors.white,
                                              )
                                            ],
                                          ),
                                          Container(
                                            height: 2,
                                          ),
                                          Container(
                                            width: 100,
                                            height: 8,
                                            color: Colors.white,
                                          )
                                        ],
                                      ),
                                    ),
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!),
                                Container(
                                  height: 10,
                                ),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.height / 3.0,
                                  child: shimmerProductItemSmall(),
                                )
                              ],
                            );
                          }
                          return Column(
                            children: [
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(
                                    left: 15, right: 15, top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: Text(
                                          value.bestProducts[0].title! ==
                                                  'Best Seller'
                                              ? AppLocalizations.of(context)!
                                                  .translate('title_hap_2')!
                                              : value.bestProducts[0].title!,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: responsiveFont(14),
                                              fontWeight: FontWeight.w600),
                                        )),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            ProductMoreScreen(
                                                              name: value
                                                                          .bestProducts[
                                                                              0]
                                                                          .title! ==
                                                                      'Best Seller'
                                                                  ? AppLocalizations.of(
                                                                          context)!
                                                                      .translate(
                                                                          'title_hap_2')!
                                                                  : value
                                                                      .bestProducts[
                                                                          0]
                                                                      .title!,
                                                              include: products
                                                                  .productBest
                                                                  .products,
                                                            )));
                                          },
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .translate('more')!,
                                            style: TextStyle(
                                                fontSize: responsiveFont(12),
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      value.bestProducts[0].description == null
                                          ? ''
                                          : value.bestProducts[0]
                                                      .description! ==
                                                  'Get The Best Products'
                                              ? AppLocalizations.of(context)!
                                                  .translate(
                                                      'description_hap_2')!
                                              : value
                                                  .bestProducts[0].description!,
                                      style: TextStyle(
                                        fontSize: responsiveFont(12),
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.justify,
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 10,
                              ),
                              ProductContainer(
                                products: value.bestProducts[0].products!,
                              )
                            ],
                          );
                        }),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 15, right: 15, top: 15, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!
                                .translate('banner_2')!,
                            style: TextStyle(
                                fontSize: responsiveFont(14),
                                fontWeight: FontWeight.w600),
                          ),
                          /*GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AllProducts()));
                            },
                            child: Text(
                              "More",
                              style: TextStyle(
                                  fontSize: responsiveFont(12),
                                  fontWeight: FontWeight.w600,
                                  color: secondaryColor),
                            ),
                          ),*/
                        ],
                      ),
                    ),
                    //Mini Banner Item start Here
                    BannerMini(typeBanner: 'love'),
                    //recently viewed item
                    buildRecentProducts,
                    Container(
                      height: 15,
                    ),
                    Container(
                      width: double.infinity,
                      height: 7,
                      color: HexColor("EEEEEE"),
                    ),
                    buildRecommendation,
                    Container(
                      height: 15,
                    ),
                    Container(
                      width: double.infinity,
                      height: 7,
                      color: HexColor("EEEEEE"),
                    ),
                    bestDealProduct()
                  ],
                ),
              ),
            ),
            Visibility(
                visible: coupons.coupons.isNotEmpty,
                child: DraggableWidget(
                  bottomMargin: 120,
                  topMargin: 60,
                  intialVisibility: true,
                  horizontalSpace: 3,
                  verticalSpace: 30,
                  normalShadow: BoxShadow(
                    color: Colors.transparent,
                    offset: Offset(0, 10),
                    blurRadius: 0,
                  ),
                  shadowBorderRadius: 50,
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CouponScreen()));
                      },
                      child: Container(
                          height: 100,
                          width: 100,
                          child: Image.asset("images/lobby/gift-coupon.gif"))),
                  initialPosition: AnchoringPosition.bottomRight,
                  dragController: dragController,
                ))
          ],
        ),
      ),
    );
  }

  Widget tabCategory(ProductCategoryModel model, int i, int count) {
    final locale = Provider.of<AppNotifier>(context, listen: false).appLocal;
    return Container(
      margin: EdgeInsets.only(
          left: locale == Locale('ar')
              ? i == count - 1
                  ? 15
                  : 0
              : i == 0
                  ? 15
                  : 0,
          right: locale == Locale('ar')
              ? i == 0
                  ? 15
                  : 0
              : i == count - 1
                  ? 15
                  : 0),
      child: Tab(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: clickIndex == model.id
                  ? primaryColor.withOpacity(0.5)
                  : Colors.white,
              border: Border.all(
                  color: clickIndex == model.id
                      ? secondaryColor
                      : HexColor("B0b0b0")),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              convertHtmlUnescape(model.name!),
              style: TextStyle(
                  fontSize: 13,
                  color: clickIndex == model.id
                      ? secondaryColor
                      : HexColor("B0b0b0")),
            )),
      ),
    );
  }

  Widget bestDealProduct() {
    final product = Provider.of<ProductProvider>(context, listen: false);

    return ListenableProvider.value(
        value: product,
        child: Consumer<ProductProvider>(builder: (context, value, child) {
          if (value.loadingBestDeals && page == 1) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: GridView.builder(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  itemCount: 6,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 2,
                      childAspectRatio: 78 / 125),
                  itemBuilder: (context, i) {
                    return GridItemShimmer();
                  }),
            );
          }
          return Visibility(
              visible: value.listBestDeal.isNotEmpty,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(
                        left: 15, bottom: 10, right: 15, top: 10),
                    child: Text(
                      AppLocalizations.of(context)!.translate('best_deals')!,
                      style: TextStyle(
                          fontSize: responsiveFont(14),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: GridView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        itemCount: value.listBestDeal.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            crossAxisCount: 2,
                            childAspectRatio: 78 / 125),
                        itemBuilder: (context, i) {
                          return GridItem(
                            i: i,
                            itemCount: value.listBestDeal.length,
                            product: value.listBestDeal[i],
                          );
                        }),
                  ),
                  if (value.loadingBestDeals && page != 1) customLoading()
                ],
              ));
        }));
  }
}

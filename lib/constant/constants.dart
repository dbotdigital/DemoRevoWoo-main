import 'package:nyoba/services/base_woo_api.dart';

String appId = '1590795778';
String url = "https://smartdealshops.com";

// oauth_consumer_key
String consumerKey = "ck_ad8173aa38af37252ba02fff123b61cc289b2918";
String consumerSecret = "cs_597416331c0911c2583bccd8040c19bf7cf4266d";

// String version = '2.5.6';

// baseAPI for WooCommerce
BaseWooAPI baseAPI = BaseWooAPI(url, consumerKey, consumerSecret);

const debugNetworkProxy = false;

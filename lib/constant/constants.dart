import 'package:nyoba/services/base_woo_api.dart';

String appId = '1590795778';
String url = "https://www.bigleagueecommerce.com";

// oauth_consumer_key
String consumerKey = "ck_26b9bc128df2b475ccec3a762afa0de72526ab32";
String consumerSecret = "cs_af622511b22e65460eda5f2eb1b55f72c83402eb";

// String version = '2.5.6';

// baseAPI for WooCommerce
BaseWooAPI baseAPI = BaseWooAPI(url, consumerKey, consumerSecret);

const debugNetworkProxy = false;

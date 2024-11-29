class ApiEndpoints {
  static const String imageBaseUrl = 'https://hayshay.gullygood.com/assets/images/';
  static const String apibaseUrl = 'https://hayshay.gullygood.com/api/';
  static const String orders = '${apibaseUrl}orders-app';
  static const String ordersCOD = '${apibaseUrl}orders-cod';
  static const String prescription = '${apibaseUrl}prescript';
  static const String pagesGet = '${apibaseUrl}pages-get';
  static String getUserPrescriptions(int userId) => '${apibaseUrl}prescriptions/user/$userId';
  static const String addAddress = '${apibaseUrl}addresses';
  static const String getAddresses = '${apibaseUrl}address-get';
  static const String updateAddress = '${apibaseUrl}addresses';
  static const String addToCart = '${apibaseUrl}add-cart';
  static const String getCart = '${apibaseUrl}cart';
  static const String clearCart = '${apibaseUrl}clear-cart';
  static const String requestOtp = '${apibaseUrl}request-otp';
  static const String verifyOtp = '${apibaseUrl}verify-otp';
  static const String getOtp = '${apibaseUrl}get-otp';
  static const String categories = '${apibaseUrl}categori';
  static const String categories_item = '${apibaseUrl}category-item';
  static const String profile = '${apibaseUrl}users';
  static const String pincode_checking = '${apibaseUrl}check-pin';
  static const String subcategories = '${apibaseUrl}subcategories';
  static const String sliders = '${apibaseUrl}sliders';
  static const String services = '${apibaseUrl}item';
  static const String search = '${apibaseUrl}items/search';
  static const String coupnecode = '${apibaseUrl}promo-codes';
  static const String profile_update = '${apibaseUrl}users_update/';
  static const String address_update = '${apibaseUrl}update-address';
  static const String updateUserLocation = '${apibaseUrl}users/';
  static const String vlogs = '${apibaseUrl}posts-app';
  static const String baseUrl = 'https://dat.babadeepsinghinfotech.com/api/';
  static const String providersList = '${baseUrl}providers/';

  static String getAddressesForUser(int userId) => '$getAddresses/$userId';
}


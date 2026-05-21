// Core app constants
class AppConstants {
  AppConstants._();

  static const String appName = 'Klinixy';
  static const String appTagline = 'Medicines at your doorstep in 30 mins';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String categoriesCollection = 'categories';
  static const String ordersCollection = 'orders';
  static const String bannersCollection = 'banners';
  static const String cartCollection = 'cart';

  // SharedPreferences keys
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyUserId = 'user_id';

  // Delivery
  static const int freeDeliveryThreshold = 499;
  static const int deliveryCharge = 30;
  static const int expressDeliveryMinutes = 30;

  // Google Maps
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
}

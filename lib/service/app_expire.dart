import 'package:tour_guide/service/expiry_date.dart';

SecureDate secureDate = SecureDate();

class AppExpire {
  static bool isAppExpired() {
  DateTime expiryDate = secureDate.date; // Set expiration date (YYYY, MM, DD)
  DateTime currentDate = DateTime.now();

  return currentDate.isAfter(expiryDate);
}
}
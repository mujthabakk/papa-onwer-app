/*Papabear*/
import 'package:ultimate_salon_owner_flutter/app/backend/api/api.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:ultimate_salon_owner_flutter/app/product/util/product_user.dart';

class TabsParser {
  final SharedPreferencesManager sharedPreferencesManager;
  final ApiService apiService;

  TabsParser(
      {required this.sharedPreferencesManager, required this.apiService});

  bool isProductUser() => ProductUser.isProduct(sharedPreferencesManager);
}

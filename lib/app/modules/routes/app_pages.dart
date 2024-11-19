import 'package:get/get.dart';

import '../Message/binding/messagebindings.dart';
import '../auth/bindings/auth_binding.dart';
import '../auth/views/loginview.dart';

import '../cart/binding/Addtocart.dart';
import '../home/binding/homebindings.dart';
import '../location/binding/location_binding.dart';
import '../location/views/locationservices.dart';
import '../offers/bindings/offersbinding.dart';
import '../profile/binding/profile_binding.dart';

import '../widgets/mainlayout.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.AUTH;

  static final routes = [
    GetPage(
      name: Routes.AUTH,
      page: () => LoginView(),
      binding: AuthBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: Routes.LOCATION,
      page: () => const LocationView(),
      binding: LocationBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const MainLayout(),
      binding: BindingsBuilder(() {
        LocationBinding().dependencies();
        HomeBindings().dependencies();
        CartBindings().dependencies();
        OffersBinding().dependencies();
        Messagebindings().dependencies();
        ProfileBindings().dependencies();
      }),
      transition: Transition.fade,
    ),
  ];
}

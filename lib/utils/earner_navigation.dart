import 'package:get/get.dart';
import 'package:jebby/views/screens/navigation/bottom_nav_controller.dart';
import 'package:jebby/views/screens/navigation/home_main.dart';

/// Keeps earner flows inside [MainScreen] so the bottom nav stays visible.
class EarnerNavigation {
  EarnerNavigation._();

  static void goHome({int tabIndex = 0}) {
    if (Get.isRegistered<BottomNavController>()) {
      Get.find<BottomNavController>().navBarChange(tabIndex);
    }
    Get.offAll(() => const MainScreen());
  }
}

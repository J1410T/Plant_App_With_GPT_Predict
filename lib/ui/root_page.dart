import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:prm_project/constants.dart';
import 'package:prm_project/models/plants.dart';
import 'package:prm_project/ui/scan_page.dart';
import 'package:prm_project/ui/screens/cart_page.dart';
import 'package:prm_project/ui/screens/favorite_page.dart';
import 'package:prm_project/ui/screens/home_page.dart';
import 'package:prm_project/ui/screens/profile_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  List<Plant> favorites = [];
  List<Plant> myCart = [];
  int _bottomNavIndex = 0;

  // Danh sách các trang
  List<Widget> _widgetOptions() {
    return [
      const HomePage(),
      FavoritePage(favoritedPlants: favorites),
      CartPage(addedToCartPlants: myCart),
      const ProfilePage(),
    ];
  }

  // Danh sách biểu tượng của các trang
  List<IconData> iconList = [
    Icons.home,
    Icons.favorite,
    Icons.shopping_cart,
    Icons.person,
  ];

  // Danh sách tiêu đề của các trang
  List<String> titleList = [
    'Home',
    'Favorite',
    'Cart',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _loadFavoritesAndCart();
  }

// Tải danh sách yêu thích và giỏ hàng từ SharedPreferences
  Future<void> _loadFavoritesAndCart() async {
    final prefs = await SharedPreferences.getInstance();

    // Tải danh sách favoritedPlantIds và selectedPlantIds
    final List<String> favoritePlantIds = prefs.getStringList('favoritePlantIds') ?? [];
    final List<String> selectedPlantIds = prefs.getStringList('selectedPlantIds') ?? [];

    // Chờ kết quả từ getPlantsByIds
    final List<Plant> favoritedPlants = await Plant.getPlantsByIds(favoritePlantIds);
    final List<Plant> addedToCartPlants = await Plant.getPlantsByIds(selectedPlantIds);

    setState(() {
      favorites = favoritedPlants;
      myCart = addedToCartPlants;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titleList[_bottomNavIndex],
              style: TextStyle(
                color: Constants.blackColor,
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),
            ),
            Icon(
              Icons.notifications,
              color: Constants.blackColor,
              size: 30.0,
            ),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: _widgetOptions(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              child: const ScanPage(),
              type: PageTransitionType.bottomToTop,
            ),
          );
        },
        child: Image.asset(
          'assets/images/code-scan-two.png',
          height: 30.0,
        ),
        backgroundColor: Constants.primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        splashColor: Constants.primaryColor,
        activeColor: Constants.primaryColor,
        inactiveColor: Colors.black.withOpacity(.5),
        icons: iconList,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
          _loadFavoritesAndCart(); // Tải lại danh sách yêu thích và giỏ hàng khi người dùng thay đổi tab
        },
      ),
    );
  }
}

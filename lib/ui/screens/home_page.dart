import 'package:flutter/material.dart';
import 'package:prm_project/constants.dart';
import 'package:prm_project/models/plants.dart';
import 'package:prm_project/ui/screens/detail_page.dart';
import 'package:prm_project/ui/screens/widgets/plant_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Plant>> _plantsFuture;
  List<String> _favoritePlantIds = [];

  @override
  void initState() {
    super.initState();
    _plantsFuture = Plant.fetchPlants(); // Lấy dữ liệu từ API
    _loadFavorites(); // Tải danh sách yêu thích từ SharedPreferences
  }

  // Tải danh sách ID các cây yêu thích từ SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoritePlantIds = prefs.getStringList('favoritePlantIds') ?? [];
    });
  }

  // Chuyển đổi trạng thái yêu thích của một cây và cập nhật SharedPreferences
  Future<void> _toggleFavorite(String plantId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoritePlantIds.contains(plantId)) {
        _favoritePlantIds.remove(plantId);
      } else {
        _favoritePlantIds.add(plantId);
      }
      prefs.setStringList('favoritePlantIds', _favoritePlantIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    int selectedIndex = 0;
    Size size = MediaQuery.of(context).size;

    List<String> _plantTypes = [
      'Recommended',
      'Indoor',
      'Outdoor',
      'Garden',
      'Supplement',
    ];

    return Scaffold(
      body: FutureBuilder<List<Plant>>(
        future: _plantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No plants available.'));
          }

          List<Plant> _plantList = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tìm kiếm
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        width: size.width * .9,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.black54.withOpacity(.6),
                            ),
                            const Expanded(
                                child: TextField(
                                  showCursor: false,
                                  decoration: InputDecoration(
                                    hintText: 'Search Plant',
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                )),
                            Icon(
                              Icons.mic,
                              color: Colors.black54.withOpacity(.6),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          color: Constants.primaryColor.withOpacity(.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      )
                    ],
                  ),
                ),

                // Danh mục cây
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 50.0,
                  width: size.width,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _plantTypes.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedIndex = index;
                              });
                            },
                            child: Text(
                              _plantTypes[index],
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: selectedIndex == index
                                    ? FontWeight.bold
                                    : FontWeight.w300,
                                color: selectedIndex == index
                                    ? Constants.primaryColor
                                    : Constants.blackColor,
                              ),
                            ),
                          ),
                        );
                      }),
                ),

                // Danh sách cây
                SizedBox(
                  height: size.height * .3,
                  child: ListView.builder(
                      itemCount: _plantList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        Plant plant = _plantList[index];
                        bool isFavorited = _favoritePlantIds.contains(plant.plantId);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: DetailPage(plantId: plant.plantId),
                                type: PageTransitionType.bottomToTop,
                              ),
                            );
                          },
                          child: Container(
                            width: 200,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 10,
                                  right: 20,
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    child: IconButton(
                                      onPressed: () async {
                                        await _toggleFavorite(plant.plantId);
                                      },
                                      icon: Icon(
                                        isFavorited ? Icons.favorite : Icons.favorite_border,
                                        color: Constants.primaryColor,
                                      ),
                                      iconSize: 30,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 50,
                                  right: 50,
                                  top: 50,
                                  bottom: 50,
                                  child: Image.network(plant.imageURL),
                                ),
                                Positioned(
                                  bottom: 15,
                                  left: 20,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plant.category,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        plant.plantName,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: 15,
                                  right: 20,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      r'$' + plant.price.toString(),
                                      style: TextStyle(
                                          color: Constants.primaryColor,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                              color: Constants.primaryColor.withOpacity(.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      }),
                ),

                // Phần "New Plants"
                Container(
                  padding: const EdgeInsets.only(left: 16, bottom: 20, top: 20),
                  child: const Text(
                    'New Plants',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: size.height * .5,
                  child: ListView.builder(
                      itemCount: _plantList.length,
                      scrollDirection: Axis.vertical,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  child: DetailPage(plantId: _plantList[index].plantId), // plantId đã là String
                                  type: PageTransitionType.bottomToTop,
                                ),
                              );
                            },
                            child: PlantWidget(index: index, plantList: _plantList));
                      }),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

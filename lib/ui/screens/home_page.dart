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
    _plantsFuture = Plant.fetchPlants(); // Take data from API
    _loadFavorites(); // Load Favorite list from SharedPreferences
  }

  // Load Favorite list ID from SharedPreferences
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoritePlantIds = prefs.getStringList('favoritePlantIds') ?? [];
    });
  }

  // Change Favorite a plant and update SharedPreferences
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
  String _removePrefix(String name) {
    // Remove the prefix "Cây " if it exists
    String result = name.startsWith("Cây ") ? name.substring(4) : name;

    // Capitalize the first letter of the result
    if (result.isNotEmpty) {
      result = result[0].toUpperCase() + result.substring(1).toLowerCase();
    }

    return result;
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
                // Search
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        width: size.width * .9,
                        decoration: BoxDecoration(
                          color: Constants.primaryColor.withOpacity(.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
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
                      )
                    ],
                  ),
                ),

                // Plant in carousel
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

                // List plant
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
                            decoration: BoxDecoration(
                              color: Constants.primaryColor.withOpacity(.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Stack(
                              children: [
                                // Favorite Icon
                                Positioned(
                                  top: 10,
                                  right: 20,
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
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
                                  ),
                                ),
                                // Image with rounded corners and shadow
                                Positioned(
                                  left: 20,
                                  right: 20,
                                  top: 70,
                                  child: Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 10,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                        plant.imageURL,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                // Plant Category and Name
                                Positioned(
                                  bottom: 15,
                                  left: 20,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Move category up by adding bottom padding
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 2), // Adjust the vertical position of category
                                        child: Text(
                                          _removePrefix(plant.category),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      // Move plant name up by adding bottom padding
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 4), // Adjust the vertical position of plant name
                                        child: Text(
                                          _removePrefix(plant.plantName),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Price Tag
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
                          ),
                        );
                      }),
                ),

                // "New Plants"
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

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:prm_project/constants.dart';
import 'package:prm_project/models/plants.dart';

class DetailPage extends StatefulWidget {
  final String plantId;
  const DetailPage({Key? key, required this.plantId}) : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Plant? _plant;
  bool _isFavorited = false;
  List<String> _selectedPlantIds = [];

  @override
  void initState() {
    super.initState();
    _fetchPlantDetails();
    _loadFavoriteStatus();
    _loadSelectedPlantIds();
  }

  Future<void> _fetchPlantDetails() async {
    final response = await http.get(
      Uri.parse('https://greenscapehub.com/api/product/single-product/${widget.plantId}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _plant = Plant.fromJson(data);
      });
    } else {
      throw Exception('Failed to load plant details');
    }
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favoritePlantIds') ?? [];
    setState(() {
      _isFavorited = favoriteIds.contains(widget.plantId);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favoritePlantIds') ?? [];

    setState(() {
      if (_isFavorited) {
        favoriteIds.remove(widget.plantId);
      } else {
        favoriteIds.add(widget.plantId);
      }
      _isFavorited = !_isFavorited;
    });

    prefs.setStringList('favoritePlantIds', favoriteIds);
  }

  Future<void> _toggleSelected(String plantId) async {
    setState(() {
      if (_selectedPlantIds.contains(plantId)) {
        _selectedPlantIds.remove(plantId);
      } else {
        _selectedPlantIds.add(plantId);
      }
    });
    await _saveSelectedPlantIds();
  }

  Future<void> _saveSelectedPlantIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedPlantIds', _selectedPlantIds);
  }

  Future<void> _loadSelectedPlantIds() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedPlantIds = prefs.getStringList('selectedPlantIds') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    if (_plant == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Constants.primaryColor.withOpacity(.15),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Constants.primaryColor,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _toggleFavorite();
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Constants.primaryColor.withOpacity(.15),
                    ),
                    child: Icon(
                      _isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: Constants.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Container(
              width: size.width * .8,
              height: size.height * .8,
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    left: 0,
                    child: SizedBox(
                      height: 350,
                      child: Image.network(_plant!.imageURL),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 0,
                    child: SizedBox(
                      height: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          PlantFeature(
                            title: 'Size',
                            plantFeature: _plant!.size,
                          ),
                          PlantFeature(
                            title: 'Humidity',
                            plantFeature: _plant!.humidity.toString(),
                          ),
                          PlantFeature(
                            title: 'Temperature',
                            plantFeature: _plant!.temperature,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 80, left: 30, right: 30),
              height: size.height * .5,
              width: size.width,
              decoration: BoxDecoration(
                color: Constants.primaryColor.withOpacity(.4),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _plant!.plantName,
                            style: TextStyle(
                              color: Constants.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 30.0,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            r'$' + _plant!.price.toString(),
                            style: TextStyle(
                              color: Constants.blackColor,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            _plant!.rating.toString(),
                            style: TextStyle(
                              fontSize: 30.0,
                              color: Constants.primaryColor,
                            ),
                          ),
                          Icon(
                            Icons.star,
                            size: 30.0,
                            color: Constants.primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  Expanded(
                    child: Text(
                      _plant!.decription,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        height: 1.5,
                        fontSize: 18,
                        color: Constants.blackColor.withOpacity(.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: size.width * .9,
        height: 50,
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              child: IconButton(
                onPressed: () async {
                  await _toggleSelected(widget.plantId);
                },
                icon: Icon(
                  Icons.shopping_cart,
                  color: _selectedPlantIds.contains(widget.plantId) ? Colors.white : Constants.primaryColor,
                ),
              ),
              decoration: BoxDecoration(
                color: _selectedPlantIds.contains(widget.plantId) ? Constants.primaryColor.withOpacity(.5) : Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 1),
                    blurRadius: 5,
                    color: Constants.primaryColor.withOpacity(.3),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Constants.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 1),
                      blurRadius: 5,
                      color: Constants.primaryColor.withOpacity(.3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'BUY NOW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlantFeature extends StatelessWidget {
  final String plantFeature;
  final String title;
  const PlantFeature({
    Key? key,
    required this.plantFeature,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Constants.blackColor,
          ),
        ),
        Text(
          plantFeature,
          style: TextStyle(
            color: Constants.primaryColor,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Plant {
  final String plantId;
  final int price;
  final String category;
  final String plantName;
  final String imageURL;
  final String decription;
  final String size;
  final double rating;
  final int humidity;
  final String temperature;

  Plant({
    required this.plantId,
    required this.price,
    required this.category,
    required this.plantName,
    required this.imageURL,
    required this.decription,
    this.size = 'Unknown',
    this.rating = 4.0,
    this.humidity = 50,
    this.temperature = '20 - 25',
  });

  // Factory method to create Plant object from JSON
  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      plantId: json['_id'] ?? '0', // Use the original _id string
      price: json['price'] ?? 0,
      category: json['category']['name'] ?? 'Unknown',
      plantName: json['title'] ?? 'No name',
      imageURL: json['img'] ?? '',
      decription: json['description'] ?? 'No description available',
    );
  }

  // Method to fetch data from API
  static Future<List<Plant>> fetchPlants() async {
    final response = await http.get(Uri.parse('https://greenscapehub.com/api/product/all'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        List<dynamic> plantsJson = data['data'];
        return plantsJson.asMap().entries.map((entry) {
          return Plant.fromJson(entry.value);
        }).toList();
      } else {
        throw Exception('Failed to load plant data');
      }
    } else {
      throw Exception('Failed to connect to API');
    }
  }

  // Method to get plants by a list of plantIds
  static Future<List<Plant>> getPlantsByIds(List<String> plantIds) async {
    // Fetch all plants
    List<Plant> allPlants = await fetchPlants();

    // Filter plants by matching IDs
    return allPlants.where((plant) => plantIds.contains(plant.plantId)).toList();
  }
}

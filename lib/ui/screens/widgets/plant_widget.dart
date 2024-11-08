import 'package:flutter/material.dart';
import 'package:prm_project/constants.dart';
import 'package:prm_project/models/plants.dart';
import 'package:prm_project/ui/screens/detail_page.dart';
import 'package:page_transition/page_transition.dart';

class PlantWidget extends StatelessWidget {
  const PlantWidget({
    Key? key, required this.index, required this.plantList,
  }) : super(key: key);

  final int index;
  final List<Plant> plantList;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                child: DetailPage(
                  plantId: plantList[index].plantId,
                ),
                type: PageTransitionType.bottomToTop));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Constants.primaryColor.withOpacity(.1),
          borderRadius: BorderRadius.circular(10),
        ),
        height: 80.0,
        padding: const EdgeInsets.only(left: 10, top: 10),
        margin: const EdgeInsets.only(bottom: 10, top: 10),
        width: size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                color: Constants.primaryColor.withOpacity(.8),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.network(
                  plantList[index].imageURL,
                  fit: BoxFit.cover, // Image will be scaled to fit inside the circle
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plantList[index].category),
                  Text(
                    plantList[index].plantName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Constants.blackColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                r'$' + plantList[index].price.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Constants.primaryColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

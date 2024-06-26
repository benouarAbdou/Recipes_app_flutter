import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ViewRecipe extends StatelessWidget {
  final String name;
  final String difficulty;
  final int numberOfIngredients;
  final String duration;

  const ViewRecipe({
    Key? key,
    required this.name,
    required this.difficulty,
    required this.numberOfIngredients,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Top container for image and back button
              Stack(
                children: [
                  Container(
                    height: 250,
                    color: const Color(0xFFFF6E6E),
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 40,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Bottom container for recipe details
          Positioned(
            top: MediaQuery.of(context).size.height / 3 - 40,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 2 / 3 + 40,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width - 200,
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 5),
                          decoration: BoxDecoration(
                              color: const Color(0xFFFF6E6E),
                              borderRadius: BorderRadius.circular(20)),
                          child: const Row(
                            children: [
                              Text(
                                "Youtube",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500),
                              ),
                              Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DescriptionElement(
                          text: difficulty,
                          icon: FontAwesomeIcons.bowlRice,
                        ),
                        DescriptionElement(
                          text: "$numberOfIngredients ingredients",
                          icon: FontAwesomeIcons.carrot,
                        ),
                        DescriptionElement(
                          text: duration,
                          icon: FontAwesomeIcons.clock,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "Ingredients",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      "Directions",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DescriptionElement extends StatelessWidget {
  const DescriptionElement({
    super.key,
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FaIcon(
          icon,
          size: 16,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

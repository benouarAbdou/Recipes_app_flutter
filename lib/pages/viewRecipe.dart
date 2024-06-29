import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recipes/database/myDataBase.dart';
import 'package:recipes/pages/addRecipe.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewRecipe extends StatefulWidget {
  final int id;

  const ViewRecipe({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  _ViewRecipeState createState() => _ViewRecipeState();
}

class _ViewRecipeState extends State<ViewRecipe> {
  late Future<Map<String, dynamic>> _recipeFuture;

  @override
  void initState() {
    super.initState();
    _recipeFuture = _fetchRecipeDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _recipeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading recipe details'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No recipe found'));
          } else {
            final recipe = snapshot.data!;
            final ingredients = recipe['Ingredients'].isEmpty
                ? []
                : (recipe['Ingredients'] as String).split('@');
            final directions = recipe['directions'] as String;
            final youtubeLink = recipe['youtubeLink'] as String;
            print(ingredients.length);
            return Stack(
              children: [
                Column(
                  children: [
                    // Top container for image and back button
                    Stack(
                      children: [
                        Container(
                          height: 250,
                          color: const Color(0xFFFF6E6E),
                          child: Center(
                            child: Image.file(
                              File(recipe['path']!),
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                return const Icon(
                                  Icons.restaurant,
                                  color: Colors.white,
                                  size: 100,
                                );
                              },
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
                        Positioned(
                          top: 40,
                          right: 40,
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _navigateToEditRecipe(recipe);
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 40),
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
                                width: MediaQuery.of(context).size.width - 200,
                                child: Text(
                                  recipe['name'],
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (_isValidYoutubeLink(youtubeLink) ||
                                  _isValidFacebookLink(youtubeLink) ||
                                  _isValidInstagramLink(youtubeLink))
                                GestureDetector(
                                  onTap: () {
                                    _launchURL(youtubeLink);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFFF6E6E),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Row(
                                      children: [
                                        const Text(
                                          "Watch",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Icon(
                                          _isValidYoutubeLink(youtubeLink)
                                              ? FontAwesomeIcons.youtube
                                              : _isValidFacebookLink(
                                                      youtubeLink)
                                                  ? FontAwesomeIcons.facebook
                                                  : FontAwesomeIcons.instagram,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DescriptionElement(
                                text: recipe['difficulty'],
                                icon: FontAwesomeIcons.fire,
                              ),
                              DescriptionElement(
                                text: recipe['type'],
                                icon: Icons.flatware,
                              ),
                              DescriptionElement(
                                text: ingredients.length > 1 ||
                                        ingredients.isEmpty
                                    ? "${ingredients.length} ingredients"
                                    : "${ingredients.length} ingredient",
                                icon: FontAwesomeIcons.carrot,
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Container(
                            height: 1,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Ingredients",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          for (var ingredient in ingredients)
                            Row(
                              children: [
                                const Text('• ',
                                    style: TextStyle(fontSize: 16)),
                                Expanded(
                                    child: Text(ingredient,
                                        style: const TextStyle(fontSize: 16))),
                              ],
                            ),
                          const SizedBox(height: 15),
                          Container(
                            height: 1,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Directions",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            directions,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchRecipeDetails() async {
    SqlDb database = SqlDb();
    final recipes = await database
        .readData('SELECT * FROM recipes WHERE recipeId = ${widget.id}');
    if (recipes.isNotEmpty) {
      return recipes.first;
    } else {
      throw Exception('Recipe not found');
    }
  }

  bool _isValidYoutubeLink(String url) {
    const youtubePattern =
        r'^https?:\/\/(?:www\.)?youtube\.com\/.*|^https?:\/\/youtu\.be\/.*';
    final regExp = RegExp(youtubePattern);
    return regExp.hasMatch(url);
  }

  bool _isValidInstagramLink(String url) {
    const instagramPattern = r'^https?:\/\/(?:www\.)?instagram\.com\/.*';
    final regExp = RegExp(instagramPattern);
    return regExp.hasMatch(url);
  }

  bool _isValidFacebookLink(String url) {
    const facebookPattern = r'^https?:\/\/(?:www\.)?facebook\.com\/.*';
    final regExp = RegExp(facebookPattern);
    return regExp.hasMatch(url);
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void _navigateToEditRecipe(Map<String, dynamic> recipe) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddRecipePage(id: recipe['recipeId'])),
    ).then((value) {
      if (value == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe edited successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
    setState(() {
      _recipeFuture = _fetchRecipeDetails();
    });
  }
}

class DescriptionElement extends StatelessWidget {
  const DescriptionElement({
    Key? key,
    required this.text,
    required this.icon,
  }) : super(key: key);

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
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

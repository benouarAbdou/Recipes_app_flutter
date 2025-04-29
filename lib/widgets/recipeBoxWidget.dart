import 'dart:io';

import 'package:flutter/material.dart';
import 'package:recipes/pages/viewRecipe.dart';

class RecipeBox extends StatelessWidget {
  final String name;
  final String difficulty;
  final String type;
  final String? imagePath; // Add imagePath parameter
  final int id;

  final VoidCallback refreshCallback; // Callback to refresh recipes
  final VoidCallback onDelete; // Callback to delete recipe
  final VoidCallback onLongPress; // Callback for long press
  final bool isSelected; // Whether this box is selected

  const RecipeBox({
    Key? key,
    required this.id,
    required this.name,
    required this.difficulty,
    required this.type,
    required this.refreshCallback, // Receive the callback
    required this.onDelete, // Receive the delete callback
    required this.onLongPress, // Receive the long press callback
    required this.isSelected, // Receive the selection status
    this.imagePath, // Receive the imagePath
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(imagePath);
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewRecipe(
                  id: id,
                ),
              ),
            ).then((value) {
              refreshCallback(); // Call the callback after navigating back
            });
          },
          onLongPress: onLongPress, // Handle long press
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 80,
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6E6E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: imagePath != null && imagePath!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(imagePath!),
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return const Icon(
                                    Icons.restaurant,
                                    color: Colors.white,
                                    size: 18,
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 18,
                            ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${type.toUpperCase()} RECIPE",
                          style: const TextStyle(
                              color: Color(0xFFFF6E6E),
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: 175,
                          child: Text(
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Text(
                          difficulty,
                        )
                      ],
                    ),
                  ],
                ),
                if (isSelected)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete, // Handle delete button press
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}

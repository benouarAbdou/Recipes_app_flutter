import 'package:flutter/material.dart';
import 'package:recipes/database/myDataBase.dart';
import 'package:recipes/pages/addRecipe.dart';
import 'package:recipes/widgets/recipeBoxWidget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipes',
      theme: ThemeData(
        fontFamily: 'Folks',
        useMaterial3: false,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFFF6E6E),
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  SqlDb database = SqlDb();
  late Future<List<Map<String, dynamic>>> _recipesFuture;
  String _searchQuery = '';
  int? _selectedRecipeId; // Keep track of the selected recipe box

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  void _fetchRecipes() {
    setState(() {
      _recipesFuture =
          database.readData('SELECT * FROM recipes ORDER BY recipeId DESC');
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<Map<String, dynamic>> _filterRecipes(
      List<Map<String, dynamic>> recipes) {
    if (_searchQuery.isEmpty) {
      return recipes;
    }
    return recipes
        .where((recipe) =>
            recipe['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _deleteRecipe(int id) async {
    await database.deleteData('DELETE FROM recipes WHERE recipeId = $id');
    _fetchRecipes();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recipe deleted successfully'),
        backgroundColor: Colors.green,
      ),
    ); // Refresh recipes after deletion
    setState(() {
      _selectedRecipeId = null; // Deselect the recipe box
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRecipeId = null; // Deselect recipe box on outside tap
        });
      },
      child: Scaffold(
        floatingActionButton: Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: FloatingActionButton(
            backgroundColor: const Color(0xFFFF6E6E),
            elevation: 0,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddRecipePage()),
              ).then((value) {
                if (value == 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Recipe added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                _fetchRecipes(); // Refresh recipes after adding a new one
              });
            },
            child: const Icon(Icons.add),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome back!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFFF6E6E),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "What recipe you want to cook today?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    onTapOutside: (event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    onChanged: _updateSearchQuery,
                    decoration: const InputDecoration(
                      hintText: "Search recipe...",
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: _recipesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error loading recipes'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No recipes found'));
                      } else {
                        final recipes = _filterRecipes(snapshot.data!);
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = recipes[index];
                            return RecipeBox(
                              id: recipe['recipeId'],
                              name: recipe['name'],
                              difficulty: recipe['difficulty'],
                              type: recipe['type'],
                              imagePath: recipe['path'], // Add imagePath
                              refreshCallback:
                                  _fetchRecipes, // Pass the callback
                              isSelected:
                                  _selectedRecipeId == recipe['recipeId'],
                              onDelete: () => _deleteRecipe(recipe['recipeId']),
                              onLongPress: () {
                                setState(() {
                                  _selectedRecipeId = recipe['recipeId'];
                                });
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

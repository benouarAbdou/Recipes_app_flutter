import 'package:flutter/material.dart';
import 'package:recipes/database/myDataBase.dart';
import 'package:recipes/pages/addRecipe.dart';
import 'package:recipes/pages/viewRecipe.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
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

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  void _fetchRecipes() {
    setState(() {
      _recipesFuture = database.readData('SELECT * FROM recipes');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              _fetchRecipes();
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
                    print('onTapOutside');
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
                      return const Center(child: Text('Error loading recipes'));
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
                            calories: recipe['calories'],
                            duration: '${recipe['durationInMinutes']} min',
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
    );
  }
}

class RecipeBox extends StatelessWidget {
  final String name;
  final String difficulty;
  final int calories;
  int id;
  final String duration;

  RecipeBox({
    Key? key,
    required this.id,
    required this.name,
    required this.difficulty,
    required this.calories,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewRecipe(
              id: id,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: MediaQuery.of(context).size.width,
        height: 60,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFF6E6E),
                borderRadius: BorderRadius.circular(10),
              ),
              width: 60,
              height: 60,
              child: const Icon(
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
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                calories > 0
                    ? Text(
                        '$difficulty - $duration - $calories calories',
                      )
                    : Text(
                        '$difficulty - $duration ',
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

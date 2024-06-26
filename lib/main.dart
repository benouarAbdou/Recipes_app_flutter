import 'package:flutter/material.dart';
import 'package:recipes/pages/viewRecipe.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          useMaterial3: false,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xFFFF6E6E),
          )),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  "What recipe you want to cook today?",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const TextField(
                      //controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search note...",
                        prefixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.all(16),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                    )),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: const [
                      RecipeBox(
                        name: 'Chicken curry',
                        difficulty: 'easy',
                        numberOfIngredients: 5,
                        duration: '25 min',
                      ),
                      RecipeBox(
                        name: 'boussou wela tmessou',
                        difficulty: 'easy',
                        numberOfIngredients: 25,
                        duration: '120 min',
                      ),
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }
}

class RecipeBox extends StatelessWidget {
  final String name;
  final String difficulty;
  final int numberOfIngredients;
  final String duration;

  const RecipeBox({
    Key? key,
    required this.name,
    required this.difficulty,
    required this.numberOfIngredients,
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
              name: name,
              difficulty: difficulty,
              numberOfIngredients: numberOfIngredients,
              duration: duration,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: MediaQuery.sizeOf(context).width,
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
            const SizedBox(
              width: 10,
            ),
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
                Text(
                  '$difficulty - $duration - $numberOfIngredients ingredients',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

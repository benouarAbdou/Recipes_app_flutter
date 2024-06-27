import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recipes/database/myDataBase.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class AddRecipePage extends StatefulWidget {
  final int? id;

  const AddRecipePage({Key? key, this.id}) : super(key: key);

  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _youtubeLinkController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _directionsController = TextEditingController();
  double _durationInMinutes = 15;
  String _difficulty = 'Easy';
  String _type = 'Dessert'; // Default value for type
  final List<String> _ingredients = [];
  List<Map<String, dynamic>> result = [];
  final List<String> _difficultyOptions = ['Easy', 'Medium', 'Hard'];
  final List<String> _typeOptions = ['Dessert', 'Lunch', 'Dinner'];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isSet = false;

  SqlDb sqlDb = SqlDb();
  late Future<void> _recipeDetailsFuture;

  @override
  void initState() {
    super.initState();
    _recipeDetailsFuture = _initializeRecipeDetails();
  }

  Future<void> _initializeRecipeDetails() async {
    if (widget.id != null) {
      await _fetchRecipeDetails();
    }
  }

  Future<void> _fetchRecipeDetails() async {
    String sql = 'SELECT * FROM recipes WHERE recipeId = ${widget.id}';
    result = await sqlDb.readData(sql);

    if (result.isNotEmpty) {
      setState(() {
        _nameController.text = result[0]['name'];
        _youtubeLinkController.text = result[0]['youtubeLink'];
        _type = result[0]['type'].toString();
        _ingredients.addAll(result[0]['Ingredients'].split('@'));
        _directionsController.text = result[0]['directions'];
        _durationInMinutes = result[0]['durationInMinutes']
            .toDouble(); // Ensure to convert to double
        _difficulty =
            result[0]['difficulty']; // Ensure to set difficulty correctly
        isSet = true;
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      String youtubeLink = _youtubeLinkController.text;
      String ingredients = _ingredients.join('@');
      String directions = _directionsController.text;
      String type = _type;
      int durationInMinutes = _durationInMinutes.toInt();
      String difficulty = _difficulty;

      String sql;
      if (widget.id == null) {
        sql = '''
          INSERT INTO recipes (name, youtubeLink, difficulty, ingredients, directions, type, durationInMinutes)
          VALUES ("$name", "$youtubeLink", "$difficulty", "$ingredients", "$directions", "$type", $durationInMinutes)
        ''';
      } else {
        sql = '''
          UPDATE recipes SET
          name = "$name",
          youtubeLink = "$youtubeLink",
          difficulty = "$difficulty",
          ingredients = "$ingredients",
          directions = "$directions",
          type = "$type",
          durationInMinutes = $durationInMinutes
          WHERE recipeId = ${widget.id}
        ''';
      }

      await sqlDb.insertData(sql);

      _nameController.clear();
      _youtubeLinkController.clear();
      _ingredientController.clear();
      _directionsController.clear();
      setState(() {
        _ingredients.clear();
        _durationInMinutes = 15;
        _difficulty = 'Easy';
        _type = 'Dessert'; // Reset type to default
      });

      Navigator.pop(context);
    }
  }

  void _addIngredient() {
    if (_ingredientController.text.isNotEmpty) {
      setState(() {
        _ingredients.add(_ingredientController.text);
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _recipeDetailsFuture,
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6E6E),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Add/Edit Recipe",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDeco("Recipe name", Icons.restaurant),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the recipe name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration:
                        InputDeco("Youtube link", FontAwesomeIcons.youtube),
                    controller: _youtubeLinkController,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          controller: _ingredientController,
                          decoration: InputDeco(
                            "Add Ingredient",
                            FontAwesomeIcons.carrot,
                            null,
                            Container(
                              height: 10,
                              width: 10,
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _addIngredient,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 5,
                    children: _ingredients
                        .asMap()
                        .entries
                        .map(
                          (entry) => Chip(
                            padding: const EdgeInsets.all(10),
                            label: Text(
                              entry.value,
                              style: const TextStyle(color: Colors.white),
                            ),
                            deleteIcon: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.white,
                            ),
                            onDeleted: () => _removeIngredient(entry.key),
                            backgroundColor: const Color(0xFFFF6E6E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    textAlignVertical: TextAlignVertical.top,
                    maxLines: 5,
                    controller: _directionsController,
                    decoration:
                        InputDeco("Directions", FontAwesomeIcons.info, 5),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the directions';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Flexible(
                        child: DropdownButtonFormField<String>(
                          value: _type,
                          decoration: InputDeco("Type", Icons.flatware),
                          items: _typeOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _type = newValue!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: DropdownButtonFormField<String>(
                          value: _difficulty,
                          decoration: InputDeco(
                              "Difficulty", FontAwesomeIcons.bowlFood),
                          items: _difficultyOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _difficulty = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Duration in Minutes: ${_durationInMinutes.toInt()}'),
                  SfSlider(
                    min: 15.0,
                    max: 120.0,
                    interval: 15,
                    stepSize: 15,
                    showTicks: true,
                    showLabels: true,
                    value: _durationInMinutes,
                    onChanged: (value) {
                      setState(() {
                        _durationInMinutes = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  TextButton(
                    onPressed: _saveRecipe,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 24.0),
                      backgroundColor: const Color(0xFFFF6E6E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Save Recipe'),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration InputDeco(String hint, IconData prefixIcon,
      [double? max, Widget? suffix]) {
    return InputDecoration(
      suffixIcon: suffix,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Align(
          alignment: Alignment.topCenter,
          widthFactor: 1.0,
          heightFactor: (max != null) ? max : 1.0,
          child: Icon(prefixIcon),
        ),
      ),
      hintText: hint,
      contentPadding: const EdgeInsets.all(16),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  }
}

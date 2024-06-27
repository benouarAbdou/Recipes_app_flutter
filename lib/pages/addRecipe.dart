import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:recipes/database/myDataBase.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _youtubeLinkController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _directionsController = TextEditingController();
  double _durationInMinutes = 15;
  String _difficulty = 'Easy';
  final List<String> _ingredients = [];

  final List<String> _difficultyOptions = ['Easy', 'Medium', 'Hard'];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  SqlDb sqlDb = SqlDb();

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      String youtubeLink = _youtubeLinkController.text;
      String ingredients = _ingredients.join('@');
      String directions = _directionsController.text;
      int calories = _caloriesController.text.isNotEmpty
          ? int.parse(_caloriesController.text)
          : 0;
      int durationInMinutes = _durationInMinutes.toInt();
      String difficulty = _difficulty;

      String sql = '''
        INSERT INTO recipes (name, youtubeLink, difficulty, Ingredients, directions, calories, durationInMinutes)
        VALUES ("$name", "$youtubeLink", "$difficulty", "$ingredients", "$directions", $calories, $durationInMinutes)
      ''';

      await sqlDb.insertData(sql);

      _nameController.clear();
      _youtubeLinkController.clear();
      _ingredientController.clear();
      _directionsController.clear();
      _caloriesController.clear();
      setState(() {
        _ingredients.clear();
        _durationInMinutes = 15;
        _difficulty = 'Easy';
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
      body: Padding(
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
                        borderRadius: BorderRadius.circular(10)),
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
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "Add a new recipe",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
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
                decoration: InputDeco("Youtube link", FontAwesomeIcons.youtube),
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
                            icon: const Icon(
                              Icons.add,
                            ),
                            onPressed: _addIngredient,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 5,
                children: _ingredients
                    .asMap()
                    .entries
                    .map((entry) => Chip(
                          padding: const EdgeInsets.all(10),
                          label: Text(
                            entry.value,
                            style: const TextStyle(
                              color: Colors.white,
                            ), // Red text color
                          ),
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.white, // Red icon color
                          ),
                          onDeleted: () => _removeIngredient(entry.key),
                          backgroundColor:
                              const Color(0xFFFF6E6E), // White background color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8), // Less round border radius
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              TextFormField(
                textAlignVertical: TextAlignVertical.top,
                maxLines: 5,
                controller: _directionsController,
                decoration: InputDeco("Directions", FontAwesomeIcons.info, 5),
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
                    child: TextFormField(
                      controller: _caloriesController,
                      decoration: InputDeco("Calories", FontAwesomeIcons.fire),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: DropdownButtonFormField<String>(
                      value: _difficulty,
                      decoration:
                          InputDeco("Difficulty", FontAwesomeIcons.bowlFood),
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
          borderRadius: BorderRadius.all(Radius.circular(10))),
    );
  }
}

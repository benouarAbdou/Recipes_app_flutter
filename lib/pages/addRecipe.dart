import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipes/database/myDataBase.dart';

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
  String _imagePath = '';
  int checker = 0;
  bool isImageSet = false;
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

  void _pasteRecipeFromClipboard() async {
    ClipboardData? clipboardData =
        await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      String clipboardText = clipboardData.text!;

      if (_isValidRecipeFormat(clipboardText)) {
        _nameController.text = _getValueFromText(clipboardText, "Recipe Name:");
        _difficulty = _getValueFromText(clipboardText, "Difficulty:");
        _type = _getValueFromText(clipboardText, "Type:");
        _ingredients.clear();
        String ingredientsSection =
            _getValueFromText(clipboardText, "Ingredients:");
        if (ingredientsSection.isNotEmpty) {
          _ingredients.addAll(ingredientsSection
              .trim()
              .split('@')
              .map((ingredient) => ingredient.trim()));
        }
        _directionsController.text =
            _getValueFromText(clipboardText, "Directions:");
        _youtubeLinkController.text =
            _getValueFromText(clipboardText, "Video Link:");

        // Set the image path if applicable
        setState(() {
          _imagePath =
              ''; // Set the image path here if you have it in the clipboard format
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid recipe format in clipboard'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isValidRecipeFormat(String text) {
    return text.contains("Recipe Name:") &&
        text.contains("Difficulty:") &&
        text.contains("Type:") &&
        text.contains("Ingredients:") &&
        text.contains("Directions:") &&
        text.contains("Video Link:");
  }

  String _getValueFromText(String text, String prefix) {
    int startIndex = text.indexOf(prefix);
    if (startIndex != -1) {
      startIndex += prefix.length;
      int endIndex = text.indexOf('\n', startIndex);
      if (endIndex == -1) {
        endIndex = text.length;
      }
      return text.substring(startIndex, endIndex).trim();
    }
    return '';
  }

  Future<void> _fetchRecipeDetails() async {
    String sql = 'SELECT * FROM recipes WHERE recipeId = ${widget.id}';
    result = await sqlDb.readData(sql);

    if (result.isNotEmpty) {
      setState(() {
        _nameController.text = result[0]['name'];
        _youtubeLinkController.text = result[0]['youtubeLink'];
        _type = result[0]['type'].toString();

        result[0]['Ingredients'].isEmpty
            ? _ingredients.clear()
            : _ingredients.addAll(result[0]['Ingredients'].split('@'));
        _directionsController.text = result[0]['directions'];
        _difficulty = result[0]['difficulty'];
        _imagePath = result[0]['path'];
        isSet = true;
        checker = _imagePath.length;
      });
    }
    print("i:$checker");
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      String youtubeLink = _youtubeLinkController.text;
      String ingredients =
          _ingredients.isNotEmpty ? _ingredients.join('@') : '';

      String directions = _directionsController.text;
      String type = _type;
      String difficulty = _difficulty;

      String sql;
      if (widget.id == null) {
        sql = '''
        INSERT INTO recipes (name, youtubeLink, difficulty, ingredients, directions, type, path)
        VALUES ("$name", "$youtubeLink", "$difficulty", "$ingredients", "$directions", "$type", "$_imagePath")
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
        path = "$_imagePath"
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
        _difficulty = 'Easy';
        _type = 'Dessert';
        _imagePath = '';
      });

      Navigator.pop(context, 1);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
        isImageSet = true;
      });
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
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Form(
              key: _formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Text(
                            widget.id != null ? "Edit Recipe" : "Add Recipe",
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(12),
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _pasteRecipeFromClipboard();
                        },
                        child: const Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.paste,
                              size: 18,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Paste Recipe'),
                          ],
                        ),
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
                    decoration: InputDeco("Video link", FontAwesomeIcons.video),
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
                  DottedBorder(
                    padding: const EdgeInsets.all(20),
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    dashPattern: const [4, 3],
                    color: Colors.grey,
                    strokeWidth: 2,
                    child: checker < 5 && !isImageSet
                        ? Center(
                            child: Column(
                              children: [
                                Text(
                                  "10.0 MB Maximum file size",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: const Color(0xFFFF6E6E),
                                        )),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Upload image",
                                          style: TextStyle(
                                            color: Color(0xFFFF6E6E),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Icon(
                                          Icons.upload_rounded,
                                          color: Color(0xFFFF6E6E),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: _pickImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: const Color(0xFFFF6E6E),
                                          )),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Change image",
                                            style: TextStyle(
                                              color: Color(0xFFFF6E6E),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Icon(
                                            Icons.upload_rounded,
                                            color: Color(0xFFFF6E6E),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 100,
                                width: 100,
                                child: Image.file(
                                    fit: BoxFit.cover, File(_imagePath)),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),
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

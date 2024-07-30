# Recipes App

## Overview
The Recipes App is a mobile application developed using Flutter and Dart. The app allows users to manage their recipes by adding, viewing, searching, and deleting recipes. It uses SQLite for local storage to maintain the database of recipes.

## Features
1. **Add Recipes**: Users can add new recipes with details like name, difficulty, type, ingredients, directions, and an optional image.
2. **View Recipes**: Users can view detailed information about each recipe.
3. **Search Recipes**: Users can search for recipes by name.
4. **Delete Recipes**: Users can delete recipes from the database.
5. **Responsive UI**: The app features a user-friendly and responsive interface.

## Project Structure
The project is structured as follows:

- `main.dart`: The entry point of the application.
- `myDataBase.dart`: Contains the `SqlDb` class for database operations.
- `addRecipe.dart`: Page for adding new recipes.
- `viewRecipe.dart`: Page for viewing recipe details.
- `RecipeBox`: A custom widget to display recipe information in a list format.

## Detailed Description

### main.dart
This is the main entry point of the app. It sets up the `MaterialApp` and defines the theme and home page of the app.

### MyApp
A `StatelessWidget` that defines the basic setup for the MaterialApp.

### MyHomePage
A `StatefulWidget` that is the home page of the app. It includes:
- Initial fetching of recipes from the database.
- Search functionality.
- Displaying the list of recipes using a `FutureBuilder`.
- Handling the addition of new recipes through navigation to `AddRecipePage`.
- Handling deletion of recipes.

### SqlDb
A class to handle all database operations including:
- Initializing the database.
- Creating tables.
- CRUD operations (Create, Read, Update, Delete).

### addRecipe.dart
Page to add a new recipe to the database. It includes a form to enter recipe details.

### viewRecipe.dart
Page to view the details of a selected recipe.


## Dependencies
- `flutter`: The main framework for building the UI.
- `sqflite`: For SQLite database operations.
- `path`: For handling file paths.

## Contributing
If you want to contribute to this project:
1. Fork the repository.
2. Create a new branch.
3. Make your changes.
4. Submit a pull request.




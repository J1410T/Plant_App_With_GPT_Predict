# Plant App - Flutter (PRM Project)
This is a Flutter-based Android app for plant lovers. It includes functionality for viewing a collection of plants, logging in to access user-specific features, managing favorites, viewing the shopping cart, and managing user profiles.

## Table of Contents

- [Features](#features)
- [Important Note](#important-notes)

- [Setup](#setup)
  - [Clone the Repository](#clone-the-repository)
  - [Configuration](#configuration)
  - [Build and Run](#build-and-run)
- [Screenshots](#screenshots)
- [Contribution](#contribution)

## Features
- Home Page: Displays a collection of plants.
- Login Page: Requires authentication to access the app.
- Favorite Page: Allows users to save and view their favorite plants.
- Cart Page: Shows the plants added to the shopping cart.
- Profile Page: Displays the user's profile information, with the option to log out.
- Disease Prediction: Uses GPT-4 to analyze images of plants and predict potential diseases. The app provides recommendations on how to care for the plants based on the analysis.

## Important Notes
1. API Token:
- Critical: When cloning this repository to your local machine, you must replace the API token in the configuration with a valid token related to plant data and user profiles. If you do not replace the API token, you will not be able to log in and the app will throw errors.
- To replace the API token, locate the configuration file (typically constants.dart or a similar configuration file), and set the appropriate token for plant-related data and user profiles.
2. API Key for GPT-4
- The disease prediction feature relies on GPT-4, which requires an API key.
- When you clone this repository, you must replace the default API key with your own GPT-4 API key. You can obtain your API key from OpenAI's platform.
- Replace the placeholder key in the api_constants.dart file with your personal API key.
3. Camera Permission
- The disease prediction feature uses your camera to capture images of plants. If you wish to use the camera feature, ensure that you have connected a camera to your laptop or phone.
- For mobile devices, the app will access the camera directly. However, for laptops or desktops, you need to ensure your camera is properly set up and accessible.
4. App Status
- The app is a work-in-progress, with some features still under development. Future releases will bring new features and improvements.
- Some functionality might not be fully implemented in the current version.

## Setup
Follow these steps to install and run App on your system.

Before you begin, ensure you have the following tools installed:
- [Android Studio](https://developer.android.com/studio?hl=vi) (because we use it for create app, you can install any IDE that you want to do)

### Clone the Repository
```sh
git clone https://github.com/J1410T/Plant_App_With_GPT_Predict.git
cd Plant_App_With_GPT_Predict
```
### Configuration
1. Install Dependencies: Run the following command to install the required Flutter dependencies:
```sh
flutter pub get
```
2. Replace the API Token:

- Find the configuration file where the API token is stored.
- Replace the placeholder API token with the token specific to the plant data and the user profile.

3. Set your API key:

- Navigate to lib/constants/api_constants.dart.
- Replace the placeholder YOUR_API_KEY with your own GPT-4 API key, which you can get from OpenAI's API key page.

### Build and Run
1. Connect your device or start an emulator.
2. To build and run the project, use the following command:
```sh
[build/run command]
```
This will build the project and install it on your connected device or emulator.

## Screenshots

![All Page in System](assets/screenshots/all_pages.png)
*Displaying the system.*



## Contribution 
Feel free to contribute to the development of the app! Fork the repository, create a pull request, and we'll review it

## Contact
For questions or inquiries, feel free to reach out to the app developer.

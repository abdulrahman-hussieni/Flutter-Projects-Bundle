plugins {
    id("com.android.application")
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
=======
>>>>>>> temp-hotel/main
=======
>>>>>>> temp-todo/main
=======
>>>>>>> temp-weather/main
=======
>>>>>>> temp-eco/main
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
    namespace = "com.example.note_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"
=======
    namespace = "com.example.hotel_booking"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
>>>>>>> temp-hotel/main
=======
    namespace = "com.todoapp.example.todoapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"
    compileSdk = flutter.compileSdkVersion
>>>>>>> temp-todo/main
=======
    namespace = "com.example.weatherapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
>>>>>>> temp-weather/main
=======
    namespace = "com.example.ecommerce1"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
>>>>>>> temp-eco/main

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
        applicationId = "com.example.note_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
=======
        applicationId = "com.example.hotel_booking"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
>>>>>>> temp-hotel/main
=======
        applicationId = "com.todoapp.example.todoapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
>>>>>>> temp-todo/main
=======
        applicationId = "com.example.weatherapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
>>>>>>> temp-weather/main
=======
        applicationId = "com.example.ecommerce1"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
>>>>>>> temp-eco/main
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

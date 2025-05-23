plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.expense_tracker_app"
    // CORRECCIÓN: Aseguramos que compileSdk sea al menos 34.
    // Esto resuelve el error "Attribute android:requestLegacyExternalStorage is not allowed here"
    // en AndroidManifest.xml si flutter.compileSdkVersion es demasiado bajo.
    // Se recomienda mantenerlo en la última versión estable (ej. 34).
    compileSdk = 34 // Antes: flutter.compileSdkVersion

    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.expense_tracker_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        // CORRECCIÓN: Aseguramos que targetSdk sea al menos 34.
        // Es buena práctica que targetSdk coincida con compileSdk.
        targetSdk = 34 // Antes: flutter.targetSdkVersion
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
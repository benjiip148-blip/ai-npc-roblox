plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.social_app"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.social_app"
        minSdk = flutter.minSdkVersion // o flutter.minSdkVersion si tienes variable
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // Kotlin DSL moderno:
        compilerOptions {
            jvmTarget.set("17")
        }
    }

    signingConfigs {
        create("debug") {
            storeFile = file(System.getenv("USERPROFILE") + "/.android/debug.keystore")
            storePassword = "android"
            keyAlias = "androiddebugkey"
            keyPassword = "android"
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

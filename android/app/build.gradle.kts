plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.codebook_app"
    compileSdk = 34
    ndkVersion = "27.0.12077973"

   defaultConfig {
    applicationId = "com.example.codebook_app"
    minSdk = flutter.minSdkVersion
    targetSdk = 34
    versionCode = flutter.versionCode
    versionName = flutter.versionName
    manifestPlaceholders["requestLegacyExternalStorage"] = true
    }


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    dependencies {
        // Needed when desugaring is enabled
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    }

    buildTypes {
        release {
            // For a real release, do NOT use debug signing.
            // We'll keep it simple for now so build succeeds.
            signingConfig = signingConfigs.getByName("debug")

            // Optional (safe defaults):
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

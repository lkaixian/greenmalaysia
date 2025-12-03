import java.util.Properties
import java.io.FileInputStream

// --- STEP 1: LOAD ENV & DEBUG ---
val localProperties = Properties()
val envFile = rootProject.file("../key.env")

print("--------------------------------------------------\n")
print("GRADLE DEBUG: Looking for .env at: ${envFile.absolutePath}\n")

if (envFile.exists()) {
    localProperties.load(FileInputStream(envFile))
    print("GRADLE DEBUG: .env file FOUND.\n")
} else {
    print("GRADLE DEBUG: .env file NOT FOUND! Please check path.\n")
}

var mapsApiKey = localProperties.getProperty("GOOGLE_MAPS_API_KEY") ?: ""

if (mapsApiKey.isEmpty()) {
    print("GRADLE DEBUG: GOOGLE_MAPS_API_KEY is empty or missing in .env.\n")
    mapsApiKey = "AIza_DUMMY_KEY_TO_FIX_BUILD_ERROR"
} else {
    // print("GRADLE DEBUG: Key loaded successfully.\n") 
}
print("--------------------------------------------------\n")
// --------------------------------

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.greenmalaysia"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.greenmalaysia"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // --- STEP 2: INJECT KEY (CORRECT KOTLIN SYNTAX) ---
        manifestPlaceholders["mapsApiKey"] = mapsApiKey
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-analytics-ktx:21.3.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
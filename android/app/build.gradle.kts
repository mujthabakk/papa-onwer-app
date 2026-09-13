import java.util.Properties
import java.io.FileReader

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")   // replaces apply from: "$flutterRoot/…"
    id("com.google.gms.google-services")      // FlutterFire
}

val localProperties = Properties().apply {
    val localPropsFile = rootProject.file("local.properties")
    if (localPropsFile.exists()) FileReader(localPropsFile, Charsets.UTF_8).use { load(it) }
}

val flutterRoot: String = localProperties.getProperty("flutter.sdk")
    ?: throw GradleException("Flutter SDK not found. Define location with flutter.sdk in local.properties")

val flutterVersionCode = (localProperties["flutter.versionCode"] ?: "1").toString().toInt()
val flutterVersionName = (localProperties["flutter.versionName"] ?: "1.0").toString()


android {
    namespace = "com.papabear.partner"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

  
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    sourceSets["main"].java.srcDir("src/main/kotlin")

    signingConfigs {
        create("release") {
            storeFile = file("papabear.keystore")
            storePassword = "papabear"
            keyAlias = "1"
            keyPassword = "papabear"
        }
    }

    defaultConfig {
        applicationId = "com.papabear.partner"
        minSdk = 24
        targetSdk = 36
        versionCode = flutterVersionCode
        versionName = flutterVersionName
    }

   
    buildTypes {
        getByName("release") {
        
 isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    val kotlinVersion = "2.1.0" // or "1.7.10"
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlinVersion")
    implementation(platform("com.google.firebase:firebase-bom:33.5.0"))
    implementation("com.google.firebase:firebase-analytics")
}

/* ----------------------------------------------------------
   Patch: supply missing namespace to pusher_channels_flutter
   ---------------------------------------------------------- */
// subprojects {
//     afterEvaluate {
//         if (name == "pusher_channels_flutter") {
//             // Correctly apply the 'namespace' property to the 'android' extension
//             // The type of the 'android' extension in a library is 'LibraryExtension'.
//             configure<com.android.build.gradle.LibraryExtension>("android") {
//                 if (namespace.isNullOrEmpty()) {
//                     namespace = "com.pusher.channels_flutter"
//                 }
//             }
//         }
//     }
// }
plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "site.tunckankilic.devshabitat"
    compileSdk = 35
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
        applicationId = "site.tunckankilic.devshabitat"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 33
        targetSdk = 35
        versionCode = 1
        versionName = "0.9.0"
        
        // MultiDex support for large apps
        multiDexEnabled = true
        
        // ProGuard configuration
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
        
        // Test instrumentation runner
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        
        // Resource configurations (for app size optimization)
        resourceConfigurations += setOf("en", "tr")
        
        // Vector drawables support for older versions
        vectorDrawables.useSupportLibrary = true
        
        // Manifest placeholders for dynamic values
        manifestPlaceholders["appAuthRedirectScheme"] = "site.tunckankilic.devshabitat"
    }

    buildTypes {
        debug {
            isDebuggable = true
            isMinifyEnabled = false
            isShrinkResources = false
            // applicationIdSuffix = ".debug"  // Firebase config uyumsuzluğu nedeniyle devre dışı
            versionNameSuffix = "-debug"
            
            // Debug-specific configurations
            buildConfigField("boolean", "DEBUG_MODE", "true")
            buildConfigField("String", "API_BASE_URL", "\"https://dev-api.devshabitat.com\"")
        }
        
        release {
            isDebuggable = false
            isMinifyEnabled = true
            isShrinkResources = true
            
            // Release-specific configurations
            buildConfigField("boolean", "DEBUG_MODE", "false")
            buildConfigField("String", "API_BASE_URL", "\"https://api.devshabitat.com\"")
            
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            
            // ProGuard/R8 configuration
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    
    // Signing configurations
    signingConfigs {
        create("release") {
            // TODO: Add your release signing configuration
            // keyAlias = "your-key-alias"
            // keyPassword = "your-key-password"
            // storeFile = file("path/to/your/keystore.jks")
            // storePassword = "your-store-password"
        }
    }
    
    // Packaging options
    packagingOptions {
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/ASL2.0",
                "META-INF/*.kotlin_module"
            )
        }
    }
    
    // Lint options
    lint {
        disable += setOf("InvalidPackage", "MissingTranslation")
        checkReleaseBuilds = false
        abortOnError = false
    }
    
    // Build features
    buildFeatures {
        buildConfig = true
        viewBinding = false
        dataBinding = false
    }
    
    // Compile options for better performance
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }
    
    // Bundle configuration
    bundle {
        language {
            enableSplit = false
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring for API level compatibility
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    
    // MultiDex support
    implementation("androidx.multidex:multidex:2.0.1")
    
    // Google Sign In
    implementation("com.google.android.gms:play-services-auth:20.7.0")
    
    // Test dependencies
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
    
    // Firebase BOM for version management
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    
    // Optional: Add specific Firebase dependencies if needed
    // implementation("com.google.firebase:firebase-analytics-ktx")
    // implementation("com.google.firebase:firebase-crashlytics-ktx")
}
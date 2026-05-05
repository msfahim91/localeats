plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
}
android {
    namespace = "com.localeats.localeats"
    compileSdk = 34
    ndkVersion = "25.0.8775105"
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    defaultConfig {
        applicationId = "com.localeats.localeats"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

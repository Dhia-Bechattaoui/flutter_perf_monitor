plugins {
    id("com.android.library")
    id("kotlin-android")
}

group = "com.github.dhia_bechattaoui"
version = "1.0-SNAPSHOT"

android {
    namespace = "com.github.dhia_bechattaoui.flutter_perf_monitor"
    compileSdk = 33
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

kotlin {
    jvmToolchain(17)
}

dependencies {
    implementation("androidx.annotation:annotation:1.5.0")
}


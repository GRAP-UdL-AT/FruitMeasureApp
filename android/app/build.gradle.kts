import java.io.FileInputStream
import java.util.Properties
import java.io.File

val keystoreProperties = Properties()

// Prefer android/key.properties, but allow project-root key.properties (one level above /android)
val keystorePropertiesFile = rootProject.file("../key.properties")

if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.anphis.es.fruit_measure_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"
    // original ndkVersion
    // ndkVersion = flutter.ndkVersion


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.anphis.es.fruit_measure_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Debug + validation to avoid opaque NPEs during :app:signReleaseBundle
            if (!keystorePropertiesFile.exists()) {
                println("[signing] key.properties NOT found at: ${keystorePropertiesFile.absolutePath}")
            } else {
                println("[signing] key.properties found at: ${keystorePropertiesFile.absolutePath}")
                println("[signing] key.properties dir: ${keystorePropertiesFile.parentFile.absolutePath}")

                val alias = keystoreProperties.getProperty("keyAlias")?.trim()
                val keyPass = keystoreProperties.getProperty("keyPassword")
                val storePass = keystoreProperties.getProperty("storePassword")
                val storeFileProp = keystoreProperties.getProperty("storeFile")?.trim()

                println("[signing] keyAlias present: ${!alias.isNullOrBlank()}")
                println("[signing] storeFile property: ${storeFileProp ?: "<null>"}")

                // Resolve storeFile robustly:
                // - absolute paths are used as-is
                // - relative paths are resolved from the directory containing key.properties
                val resolvedStoreFile = when {
                    storeFileProp.isNullOrBlank() -> null
                    File(storeFileProp).isAbsolute -> File(storeFileProp)
                    else -> File(keystorePropertiesFile.parentFile, storeFileProp)
                }

                if (resolvedStoreFile == null) {
                    throw GradleException("[signing] storeFile is missing in key.properties")
                }

                println("[signing] resolved keystore path: ${resolvedStoreFile.absolutePath}")
                println("[signing] keystore exists: ${resolvedStoreFile.exists()}")

                if (!resolvedStoreFile.exists()) {
                    throw GradleException(
                        "[signing] Keystore file not found at ${resolvedStoreFile.absolutePath}. " +
                            "Fix key.properties storeFile or move the .jks there."
                    )
                }

                if (alias.isNullOrBlank()) {
                    throw GradleException("[signing] keyAlias is missing/blank in key.properties")
                }
                if (keyPass.isNullOrBlank()) {
                    throw GradleException("[signing] keyPassword is missing/blank in key.properties")
                }
                if (storePass.isNullOrBlank()) {
                    throw GradleException("[signing] storePassword is missing/blank in key.properties")
                }

                keyAlias = alias
                keyPassword = keyPass
                storeFile = resolvedStoreFile
                storePassword = storePass
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(17))
    }
}

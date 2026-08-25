import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

// Firma de release. `android/key.properties` NUNCA se versiona (ver
// android/.gitignore y SECURITY en README). Si no existe —por ejemplo en un
// clone recién hecho o en un PR de fuera— se compila con la firma de debug,
// para que `flutter build` siga funcionando sin secretos.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "cl.elkiosko.almacen"

    // Fijados a propósito en vez de heredar `flutter.*`: así una actualización
    // del SDK de Flutter no mueve en silencio el target con el que publicamos.
    // Google Play exige API 36 para apps nuevas desde el 31-08-2026.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // `flutter_local_notifications` usa java.time, que en minSdk 24 no
        // existe: sin esto el build de release falla en `checkAarMetadata`.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "cl.elkiosko.almacen"
        // minSdk 24 (Android 7.0): cubre prácticamente todo el parque activo
        // de teléfonos económicos sin arrastrar compatibilidad antigua.
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Sin `resourceConfigurations`: quedó de cuando la app era sólo para
        // Chile y habría podado los recursos de todo idioma que no fuera
        // español. La poda por idioma la hace Play con los splits de abajo,
        // que entregan a cada teléfono sólo el suyo.
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    bundle {
        // Play entrega sólo el idioma/densidad/ABI que el teléfono necesita.
        language { enableSplit = true }
        density { enableSplit = true }
        abi { enableSplit = true }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // La versión la fija el plugin de avisos: `flutter_local_notifications`
    // compila contra 2.1.4 y la del app no puede ser menor.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}

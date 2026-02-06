plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 환경변수 로드 (.env 파일)
val envFile = project.rootProject.file("../.env")
val envProperties = java.util.Properties()
if (envFile.exists()) {
    envFile.inputStream().use { envProperties.load(it) }
}

fun getEnvProperty(key: String): String {
    return envProperties.getProperty(key) ?: System.getenv(key) ?: ""
}

android {
    namespace = "xyz.gaegulzip.wowa"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "xyz.gaegulzip.wowa"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 소셜 로그인 환경변수 주입
        manifestPlaceholders["KAKAO_APP_KEY"] = getEnvProperty("KAKAO_NATIVE_APP_KEY")

        resValue("string", "naver_client_id", getEnvProperty("NAVER_CLIENT_ID"))
        resValue("string", "naver_client_secret", getEnvProperty("NAVER_CLIENT_SECRET"))
        resValue("string", "naver_client_name", getEnvProperty("NAVER_CLIENT_NAME"))

        // AdMob 환경변수 주입
        resValue("string", "admob_app_id", getEnvProperty("ADMOB_APP_ID_ANDROID"))
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

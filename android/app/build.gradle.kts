import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// M16/T16.4 正式签名：从 android/key.properties 读取（该文件不入库）。
// 缺失时 release 回退 debug 签名（仅供本地/CI 跑通流程）。
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.ben.claude_flutter_v2.flutter_claude_app_v2"
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
        applicationId = "com.ben.claude_flutter_v2.flutter_claude_app_v2"
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String?
                keyPassword = keystoreProperties["keyPassword"] as String?
                storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            // 有 key.properties 用正式签名，否则回退 debug（让 `flutter run --release` 可用）。
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // M16/T16.6 代码压缩 + 资源压缩 + 混淆（配合 proguard-rules.pro）。
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }

    // M15/T15.2 多环境 flavor：dev / staging / prod。
    // - applicationIdSuffix：dev/staging 改包名，便于三套并存安装；prod 用基础包名。
    // - manifestPlaceholders["appName"]：AndroidManifest 的 android:label="${appName}" 取此值。
    // 说明：未跑破坏性的 `flutter_flavorizr` 处理器（会覆盖本项目既有原生配置：
    // 深链 host、权限、CocoaPods 固定、启动页）；此处手写等价配置。声明式来源见
    // 项目根 flavorizr.yaml。构建需带 --flavor，如：
    //   flutter build apk --flavor dev -t lib/main_dev.dart
    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            manifestPlaceholders["appName"] = "CCD Dev"
        }
        create("staging") {
            dimension = "env"
            applicationIdSuffix = ".staging"
            manifestPlaceholders["appName"] = "CCD Staging"
        }
        create("prod") {
            dimension = "env"
            manifestPlaceholders["appName"] = "CCD"
        }
    }
}

flutter {
    source = "../.."
}

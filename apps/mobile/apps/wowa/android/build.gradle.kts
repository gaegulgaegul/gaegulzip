allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// 레거시 플러그인 워크어라운드 (AGP 8.0+)
// :app은 evaluationDependsOn으로 이미 평가됨 → afterEvaluate 불가, 별도 처리 불필요
subprojects {
    if (name != "app") {
        afterEvaluate {
            extensions.findByType<com.android.build.gradle.LibraryExtension>()?.let { lib ->
                // namespace 미지정 플러그인 자동 주입
                if (lib.namespace.isNullOrEmpty()) {
                    val manifest = file("src/main/AndroidManifest.xml")
                    if (manifest.exists()) {
                        val match = Regex("""package="([^"]+)"""").find(manifest.readText())
                        lib.namespace = match?.groupValues?.get(1)
                    }
                }
                // compileSdk 낮은 플러그인 강제 업그레이드 (Java 17 컴파일 필수)
                if (lib.compileSdk != null && lib.compileSdk!! < 35) {
                    lib.compileSdk = 35
                }
                // JVM 타겟 불일치 방지 (Java↔Kotlin 동일하게 17)
                lib.compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
            // Kotlin JVM 타겟도 afterEvaluate에서 덮어쓰기 (플러그인 자체 설정 이후)
            extensions.findByType<org.jetbrains.kotlin.gradle.dsl.KotlinAndroidProjectExtension>()?.let {
                it.compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

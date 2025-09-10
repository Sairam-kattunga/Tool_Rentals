// Top-level build.gradle.kts

plugins {
    // Let Flutter manage versions to avoid conflicts
    id("com.android.application") apply false
    id("com.android.library") apply false
    id("org.jetbrains.kotlin.android") apply false

    // ✅ Firebase / Google Services (remove version)
    id("com.google.gms.google-services") apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Custom build directory handling
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

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

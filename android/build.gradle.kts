// android/build.gradle.kts

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:7.3.0")
        classpath("com.google.gms:google-services:4.4.4") // google services plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.20")
    }
}

// repositories for all projects/modules
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// move the build outputs to a parent folder (optional, kept from your file)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

// ensure :app is evaluated early if you need that
subprojects {
    project.evaluationDependsOn(":app")
}

// register a clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// 1. الجزء ده هو اللي كان ناقص في الكود اللي بعتيه
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // السطر ده هو اللي هيخلي المشروع يشوف ملف الـ JSON
        classpath("com.google.gms:google-services:4.3.15")
    }
}

// 2. ده بقية الكود اللي كان عندك زي ما هو
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}


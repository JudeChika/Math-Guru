allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// THIS IS THE CRITICAL FIX:
// It intercepts Gradle's default build directory and forces it to output
// to the root "../build" folder exactly where the Flutter SDK expects it.
val newBuildDir = File(rootProject.projectDir, "../build")
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = File(newBuildDir, project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)

    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
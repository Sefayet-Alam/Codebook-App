import org.gradle.api.file.Directory
import org.gradle.api.tasks.Delete
import com.android.build.api.dsl.ApplicationExtension
import com.android.build.api.dsl.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    afterEvaluate {
        val ext = extensions.findByName("android")
        when (ext) {
            is ApplicationExtension -> {
                ext.compileSdk = 34
                ext.defaultConfig {
                    minSdk = 23
                    targetSdk = 34
                }
            }
            is LibraryExtension -> {
                ext.compileSdk = 34
                ext.defaultConfig {
                    minSdk = 23
                    targetSdk = 34
                }
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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

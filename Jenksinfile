pipeline {
    agent any

    environment {
        // Use the JDK installed in your build_petclinic.sh script (Java 25)
        JAVA_HOME = "/home/wagih/java/jdk-25.0.1"
        PATH = "/home/wagih/java/jdk-25.0.1/bin:${env.PATH}"

        // Build script inside your repo
        BUILD_SCRIPT = "${WORKSPACE}/scripts/build_petclinic.sh"

        // The WAR produced by the build script
        BUILD_DIR    = "${WORKSPACE}/builds"
        WAR_NAME     = "petclinic.war"

        // Tomcat portable installation
        TOMCAT_HOME    = "/home/wagih/tomcat"
        TOMCAT_WEBAPPS = "/home/wagih/tomcat/webapps"
    }

    stages {

        stage('Clone') {
            steps {
                echo "=== Cloning Repo ==="
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo "=== Running build_petclinic.sh (Java 25) ==="
                sh "bash ${BUILD_SCRIPT}"
            }
        }

        stage('Test') {
            steps {
                echo "=== Running Test Stage (but skipping) ==="
                sh """
                   cd src/spring-petclinic
                   JAVA_HOME=${JAVA_HOME} ./mvnw test -DskipTests
                """
            }
        }

        stage('Package') {
            steps {
                echo "=== Packaging WAR again (safe) ==="
                sh """
                   cd src/spring-petclinic
                   JAVA_HOME=${JAVA_HOME} ./mvnw package -DskipTests
                """
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                echo "=== Deploying WAR to Tomcat (port 9090) ==="

                // Stop Tomcat safely
                sh "bash ${TOMCAT_HOME}/bin/shutdown.sh || true"

                // Clean previous deployment
                sh "rm -rf ${TOMCAT_WEBAPPS}/petclinic ${TOMCAT_WEBAPPS}/petclinic.war"

                // Copy the WAR produced by your build script
                sh "cp ${BUILD_DIR}/${WAR_NAME} ${TOMCAT_WEBAPPS}/petclinic.war"

                // Start Tomcat again
                sh "bash ${TOMCAT_HOME}/bin/startup.sh"
            }
        }
    }

    post {
        success {
            echo "🎉 SUCCESS: PetClinic deployed!"
            echo "Open: http://127.0.0.1:9090/petclinic"
        }
        failure {
            echo "❌ Pipeline Failed — check console output."
        }
    }
}

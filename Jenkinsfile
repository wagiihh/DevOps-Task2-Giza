pipeline {
    agent any

    environment {
        JAVA_HOME = "/usr/lib/jvm/java-21-openjdk-arm64"
        PATH = "${JAVA_HOME}/bin:${env.PATH}"

        // Real WAR path produced by your build script
        WAR_PATH = "/home/wagih/.ansible/tmp/builds/petclinic.war"

        // Tomcat installation
        TOMCAT_HOME    = "/home/wagih/tomcat"
        TOMCAT_WEBAPPS = "/home/wagih/tomcat/webapps"

        // Build script path inside repo
        BUILD_SCRIPT = "${WORKSPACE}/scripts/build_petclinic.sh"
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
                echo "=== Running build_petclinic.sh ==="
                sh "bash ${BUILD_SCRIPT}"
            }
        }

        stage('Test') {
            steps {
                echo "=== Running Tests ==="
                sh """
                   cd src/spring-petclinic
                   JAVA_HOME=${JAVA_HOME} ./mvnw test
                """
            }
        }

        stage('Package') {
            steps {
                echo "=== Packaging WAR (skipTests) ==="
                sh """
                   cd src/spring-petclinic
                   JAVA_HOME=${JAVA_HOME} ./mvnw package -DskipTests
                """
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                echo "=== Deploying WAR to Tomcat ==="

                // Stop Tomcat gracefully
                sh "bash ${TOMCAT_HOME}/bin/shutdown.sh || true"

                // Clean previous deployment
                sh "rm -rf ${TOMCAT_WEBAPPS}/petclinic*"

                // Copy REAL WAR from Ansible tmp path
                sh "cp ${WAR_PATH} ${TOMCAT_WEBAPPS}/petclinic.war"

                // Restart Tomcat
                sh "bash ${TOMCAT_HOME}/bin/startup.sh"
            }
        }
    }

    post {
        success {
            echo "🎉 SUCCESS → http://127.0.0.1:9090/petclinic"
        }
        failure {
            echo "❌ Failed — check console output"
        }
    }
}

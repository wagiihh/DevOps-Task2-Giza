pipeline {
    agent any

    environment {
        JAVA_HOME = "/home/wagih/java/jdk-25.0.1"
        PATH = "/home/wagih/java/jdk-25.0.1/bin:${env.PATH}"

        BUILD_SCRIPT = "${WORKSPACE}/scripts/build_petclinic.sh"
        BUILD_DIR    = "${WORKSPACE}/builds"
        WAR_NAME     = "petclinic.war"

        TOMCAT_HOME    = "/home/wagih/tomcat"
        TOMCAT_WEBAPPS = "/home/wagih/tomcat/webapps"
    }

    stages {

        stage('Clean Workspace') {
            steps {
                echo "=== Cleaning workspace to avoid duplicate clone errors ==="
                cleanWs()
            }
        }

        stage('Clone') {
            steps {
                echo "=== Cloning Repo ==="
                checkout scm
            }
        }

        stage('Build WAR') {
            steps {
                echo "=== Building PetClinic WAR (Java 25) ==="
                sh "bash ${BUILD_SCRIPT}"
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                echo "=== Deploying WAR to Tomcat ==="

                // Stop Tomcat safely
                sh "bash -lc '${TOMCAT_HOME}/bin/shutdown.sh || true'"

                // Clean old deployment
                sh "rm -rf ${TOMCAT_WEBAPPS}/petclinic ${TOMCAT_WEBAPPS}/petclinic.war"

                // Copy new WAR
                sh "cp ${BUILD_DIR}/${WAR_NAME} ${TOMCAT_WEBAPPS}/petclinic.war"

                // Start Tomcat (must use bash -l)
                sh "bash -lc '${TOMCAT_HOME}/bin/startup.sh'"
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

pipeline {
    agent any

    environment {
        // Dynamic user home directory
        USER_HOME       = "/home/${env.USER}"
        ANSIBLE_USER    = "${env.USER}"

        // Java 25 user-mode installation
        JAVA_HOME       = "${USER_HOME}/java/jdk-25.0.1"
        PATH            = "${JAVA_HOME}/bin:${env.PATH}"

        // Build script + WAR paths
        BUILD_SCRIPT    = "${WORKSPACE}/scripts/build_petclinic.sh"
        BUILD_DIR       = "${USER_HOME}/task2/builds"
        WAR_NAME        = "petclinic.war"

        // Tomcat portable installation
        TOMCAT_HOME     = "${USER_HOME}/tomcat"
        TOMCAT_WEBAPPS  = "${USER_HOME}/tomcat/webapps"

        // Correct URL (with trailing slash)
        APP_URL         = "http://127.0.0.1:9090/petclinic/"
    }

    stages {

        // Clean workspace
        stage('Clean Workspace') {
            steps {
                echo "=== Cleaning Jenkins workspace ==="
                cleanWs()
            }
        }

        // Clone repository
        stage('Checkout Repo') {
            steps {
                echo "=== Checking out code ==="
                checkout scm
            }
        }

        // Build WAR using your build_petclinic.sh script
        stage('Build WAR') {
            steps {
                echo "=== Building PetClinic WAR using Java 25 ==="
                sh "bash ${BUILD_SCRIPT}"
            }
        }

        // Deploy WAR to portable Tomcat
        stage('Deploy to Tomcat') {
            steps {
                echo "=== Deploying WAR to Tomcat ==="

                // Stop Tomcat safely
                sh "bash -lc '${TOMCAT_HOME}/bin/shutdown.sh || true'"

                // Remove old deployment
                sh "rm -rf ${TOMCAT_WEBAPPS}/petclinic ${TOMCAT_WEBAPPS}/petclinic.war"

                // Copy new WAR
                sh "cp ${BUILD_DIR}/${WAR_NAME} ${TOMCAT_WEBAPPS}/petclinic.war"

                // Start Tomcat
                sh "bash -lc '${TOMCAT_HOME}/bin/startup.sh'"
            }
        }

        // Health Check (FIXED: follow redirects with -L)
        stage('Health Check') {
            steps {
                echo "=== Checking PetClinic Health ==="
                script {
                    def retries = 10
                    def success = false

                    for (int i = 0; i < retries; i++) {

                        def code = sh(
                            script: "curl -L -s -o /dev/null -w \"%{http_code}\" ${APP_URL}",
                            returnStdout: true
                        ).trim()

                        echo "HTTP Response: ${code}"

                        // PetClinic is healthy when HTTP 200 OK
                        if (code == "200") {
                            echo "PetClinic is UP!"
                            success = true
                            break
                        }

                        echo "PetClinic not ready yet. Retrying..."
                        sleep 5
                    }

                    if (!success) {
                        error("PetClinic did NOT start after deployment.")
                    }
                }
            }
        }
    }

    // Final status
    post {
        success {
            echo "🎉 SUCCESS: PetClinic deployed successfully!"
            echo "Open: http://127.0.0.1:9090/petclinic/"
        }
        failure {
            echo "❌ Pipeline FAILED — check logs."
        }
    }
}

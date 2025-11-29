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

        // ==========================
        // 1) CLEAN WORKSPACE
        // ==========================
        stage('Clean Workspace') {
            steps {
                echo "=== Cleaning Jenkins workspace ==="
                cleanWs()
            }
        }

        // ==========================
        // 2) CLONE REPO
        // ==========================
        stage('Checkout Repo') {
            steps {
                echo "=== Checking out code ==="
                checkout scm
            }
        }

        // ==========================
        // 3) BUILD WAR
        // ==========================
        stage('Build WAR') {
            steps {
                echo "=== Building PetClinic WAR ==="
                sh "bash ${BUILD_SCRIPT}"
            }
        }

        // ==========================
        // 4) DEPLOY TO TOMCAT (FIXED)
        // ==========================
        stage('Deploy to Tomcat') {
            steps {
                echo "=== Deploying WAR to Tomcat ==="

                // ---- KILL ANY EXISTING TOMCAT INSTANCE ----
                echo "Stopping any running Tomcat process..."
                sh "pkill -f 'tomcat' || true"
                sleep 2

                // ---- CLEAN OLD DEPLOYMENT ----
                sh "rm -rf ${TOMCAT_WEBAPPS}/petclinic ${TOMCAT_WEBAPPS}/petclinic.war"

                // ---- COPY NEW WAR ----
                sh "cp ${BUILD_DIR}/${WAR_NAME} ${TOMCAT_WEBAPPS}/petclinic.war"

                // ---- START TOMCAT ----
                sh "bash -lc '${TOMCAT_HOME}/bin/startup.sh'"
            }
        }

        // ==========================
        // 5) HEALTH CHECK (FIXED: -L)
        // ==========================
        stage('Health Check') {
            steps {
                echo "=== Checking PetClinic Health ==="
                script {
                    def retries = 12
                    def success = false

                    for (int i = 0; i < retries; i++) {

                        def code = sh(
                            script: "curl -L -s -o /dev/null -w \"%{http_code}\" ${APP_URL}",
                            returnStdout: true
                        ).trim()

                        echo "HTTP Response: ${code}"

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

    // ==========================
    // FINAL STATUS
    // ==========================
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

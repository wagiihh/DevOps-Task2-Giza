pipeline {
    agent any

    environment {
        // Dynamic user home directory (NO hardcoding)
        USER_HOME       = "/home/${env.USER}"

	ANSIBLE_USER= "${env.USER}"

        // Java 25 user-mode installation
        JAVA_HOME       = "${USER_HOME}/java/jdk-25.0.1"
        PATH            = "${JAVA_HOME}/bin:${env.PATH}"

        // Paths for build script
        BUILD_SCRIPT    = "${WORKSPACE}/scripts/build_petclinic.sh"
        BUILD_DIR       = "${WORKSPACE}/builds"
        WAR_NAME        = "petclinic.war"

        // Tomcat portable installation
        TOMCAT_HOME     = "${USER_HOME}/tomcat"
        TOMCAT_WEBAPPS  = "${USER_HOME}/tomcat/webapps"

        // Health check URL
        APP_URL         = "http://127.0.0.1:9090/petclinic"
    }

    stages {

        stage('Clean Workspace') {
            steps {
                echo "=== Cleaning workspace ==="
                cleanWs()
            }
        }

        stage('Checkout Repo') {
            steps {
                echo "=== Cloning Git repository ==="
                checkout scm
            }
        }

        stage('Build WAR') {
            steps {
                echo "=== Building PetClinic WAR using Java 25 ==="
                sh "bash ${BUILD_SCRIPT}"
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                echo "=== Deploying WAR to Tomcat ==="

                // 1) Stop Tomcat safely
                sh "bash -lc '${TOMCAT_HOME}/bin/shutdown.sh || true'"

                // 2) Clean old deployment
                sh "rm -rf ${TOMCAT_WEBAPPS}/petclinic ${TOMCAT_WEBAPPS}/petclinic.war"

                // 3) Copy new WAR to Tomcat
                sh "cp ${BUILD_DIR}/${WAR_NAME} ${TOMCAT_WEBAPPS}/petclinic.war"

                // 4) Start Tomcat using login shell
                sh "bash -lc '${TOMCAT_HOME}/bin/startup.sh'"
            }
        }

        stage('Health Check') {
            steps {
                echo "=== Checking if PetClinic is responding ==="

                script {
                    def retries = 10
                    def success = false

                    for (int i = 0; i < retries; i++) {
                        def code = sh(
                            script: "curl -s -o /dev/null -w \"%{http_code}\" ${APP_URL}",
                            returnStdout: true
                        ).trim()

                        if (code == "200") {
                            echo "PetClinic is UP (HTTP 200)"
                            success = true
                            break
                        } else {
                            echo "PetClinic not ready yet (HTTP ${code}). Retrying..."
                            sleep 5
                        }
                    }

                    if (!success) {
                        error("PetClinic did NOT start after deployment.")
                    }
                }
            }
        }
    }

    post {
        success {
            echo "🎉 SUCCESS: PetClinic deployed successfully!"
            echo "Open in browser: http://127.0.0.1:9090/petclinic"
        }
        failure {
            echo "❌ Pipeline FAILED — check console logs."
        }
    }
}

pipeline {
    agent any

    environment {
        USER_HOME    = "/home/${env.USER}"

        // Java 25 user-mode
        JAVA_HOME    = "${USER_HOME}/java/jdk-25.0.1"
        PATH         = "${JAVA_HOME}/bin:${env.PATH}"

        // Build script + build output
        BUILD_SCRIPT = "${WORKSPACE}/scripts/build_petclinic.sh"
        BUILD_DIR    = "${USER_HOME}/task2/builds"
        WAR_NAME     = "petclinic.war"

        // Tomcat portable
        TOMCAT_HOME    = "${USER_HOME}/tomcat"
        TOMCAT_WEBAPPS = "${USER_HOME}/tomcat/webapps"

        // URL for health check
        APP_URL = "http://127.0.0.1:9090/petclinic/"
    }

    stages {

        stage('Clean Workspace') {
            steps {
                echo "=== Cleaning old Jenkins workspace ==="
                cleanWs()
            }
        }

        stage('Checkout Repo') {
            steps {
                echo "=== Checking out source code ==="
                checkout scm
            }
        }

        stage('Build WAR') {
            steps {
                echo "=== Running build script (Maven + Java 25) ==="
                sh "bash ${BUILD_SCRIPT}"

                echo "=== Waiting for WAR to finish writing ==="
                sh """
                while [ ! -s ${BUILD_DIR}/${WAR_NAME} ]; do
                    echo 'WAR not ready yet...'
                    sleep 1
                done
                """
                sleep 2 // filesystem flush
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                echo "=== Stopping existing Tomcat ==="
                sh "pkill -f 'tomcat' || true"
                sleep 2

                echo "=== Cleaning old deployment ==="
                sh "rm -rf ${TOMCAT_WEBAPPS}/petclinic ${TOMCAT_WEBAPPS}/petclinic.war"

                echo "=== Copying new WAR ==="
                sh "cp ${BUILD_DIR}/${WAR_NAME} ${TOMCAT_WEBAPPS}/petclinic.war"

                echo "=== Starting Tomcat ==="
                sh "bash -lc '${TOMCAT_HOME}/bin/startup.sh'"
                sleep 3
            }
        }

        stage('Health Check') {
            steps {
                script {
                    echo "=== Checking application health ==="
                    def retries = 15
                    def success = false

                    for (int i = 0; i < retries; i++) {
                        def code = sh(
                            script: "curl -s -o /dev/null -w \"%{http_code}\" ${APP_URL}",
                            returnStdout: true
                        ).trim()

                        echo "Response: ${code}"

                        if (code == "200") {
                            success = true
                            break
                        }

                        sleep 4
                    }

                    if (!success) {
                        error("❌ PetClinic is NOT responding.")
                    }
                }
            }
        }
    }

    post {
        success {
            echo "🎉 SUCCESS: PetClinic deployed and running at ${APP_URL}"
        }
        failure {
            echo "❌ FAILURE: Check logs and WAR build output."
        }
    }
}

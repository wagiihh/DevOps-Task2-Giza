pipeline {
    agent any

    environment {
        USER_HOME    = "/home/${env.USER}"

        // Java 25 user-mode
        JAVA_HOME    = "${USER_HOME}/java/jdk-25.0.1"
        PATH         = "${JAVA_HOME}/bin:${env.PATH}"

        // Required for your build_petclinic.sh
        ANSIBLE_USER = "${env.USER}"

        // Build script and WAR details
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

                // Export ANSIBLE_USER for the build script
                sh """
                export ANSIBLE_USER=${env.USER}
                bash ${BUILD_SCRIPT}
                """

                echo "=== Ensuring WAR is fully written ==="
                sh """
                while [ ! -s ${BUILD_DIR}/${WAR_NAME} ]; do
                    echo 'WAR not ready yet...'
                    sleep 1
                done
                """
                sleep 2
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

                echo "=== Starting Tomcat in detached mode ==="
                sh """
                    nohup ${TOMCAT_HOME}/bin/startup.sh >/dev/null 2>&1 &
                """

                echo "=== Waiting for Tomcat to initialize ==="
                sleep 4
            }
        }

        stage('Health Check') {
            steps {
                script {
                    echo "=== Performing health check ==="
                    def retries = 15
                    def success = false

                    for (int i = 0; i < retries; i++) {
                        def code = sh(
                            script: "curl -s -o /dev/null -w \"%{http_code}\" ${APP_URL}",
                            returnStdout: true
                        ).trim()

                        echo "HTTP Response: ${code}"

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
            echo "🎉 SUCCESS: PetClinic deployed successfully!"
            echo "Open: ${APP_URL}"
        }
        failure {
            echo "❌ FAILURE: Check logs and WAR build output."
        }
    }
}

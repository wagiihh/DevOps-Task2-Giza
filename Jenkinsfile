pipeline {
    agent any

    environment {
        USER_HOME       = "/home/${env.USER}"
        ANSIBLE_USER    = "${env.USER}"

        JAVA_HOME       = "${USER_HOME}/java/jdk-25.0.1"
        PATH            = "${JAVA_HOME}/bin:${env.PATH}"

        BUILD_SCRIPT    = "${WORKSPACE}/scripts/build_petclinic.sh"
        BUILD_DIR       = "${USER_HOME}/task2/builds"   // FIXED HERE
        WAR_NAME        = "petclinic.war"

        TOMCAT_HOME     = "${USER_HOME}/tomcat"
        TOMCAT_WEBAPPS  = "${USER_HOME}/tomcat/webapps"

        APP_URL         = "http://127.0.0.1:9090/petclinic"
    }

    stages {

        stage('Clean Workspace') {
            steps { cleanWs() }
        }

        stage('Checkout Repo') {
            steps { checkout scm }
        }

        stage('Build WAR') {
            steps {
                sh "bash ${BUILD_SCRIPT}"
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                sh "bash -lc '${TOMCAT_HOME}/bin/shutdown.sh || true'"
                sh "rm -rf ${TOMCAT_WEBAPPS}/petclinic ${TOMCAT_WEBAPPS}/petclinic.war"
                sh "cp ${BUILD_DIR}/${WAR_NAME} ${TOMCAT_WEBAPPS}/petclinic.war"
                sh "bash -lc '${TOMCAT_HOME}/bin/startup.sh'"
            }
        }

        stage('Health Check') {
            steps {
                script {
                    def retries = 10
                    def success = false

                    for (int i = 0; i < retries; i++) {
                        def code = sh(
                            script: "curl -s -o /dev/null -w \"%{http_code}\" ${APP_URL}",
                            returnStdout: true
                        ).trim()

                        if (code == "200") {
                            success = true
                            break
                        }
                        sleep 5
                    }

                    if (!success) error("PetClinic did NOT start.")
                }
            }
        }
    }

    post {
        success { echo "SUCCESS!" }
        failure { echo "Pipeline FAILED" }
    }
}

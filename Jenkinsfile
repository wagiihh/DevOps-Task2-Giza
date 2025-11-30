pipeline {
    agent any

    environment {
        USER_HOME = "/home/${env.USER}"

        // Java 25 user-mode config (same as deploy.yml)
        JAVA_HOME = "${USER_HOME}/java/jdk-25.0.1"
        PATH = "${JAVA_HOME}/bin:${env.PATH}"

        // Build script and WAR details
        PROJECT_ROOT = "${USER_HOME}/task2"
        BUILD_SCRIPT = "${WORKSPACE}/scripts/build_petclinic.sh"
        BUILD_DIR = "${USER_HOME}/task2/builds"
        WAR_NAME = "petclinic.war"

        // Ansible deploy files
        INVENTORY = "${WORKSPACE}/inventory"
        DEPLOY_PLAY = "${WORKSPACE}/deploy.yml"
    }

    stages {

        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout Repo') {
            steps {
                checkout scm
            }
        }

        stage('Build WAR') {
            steps {
                echo "=== Building PetClinic WAR with Java 25 ==="

                // EXACT equivalent of your Ansible block:
                //   chdir: PROJECT_ROOT
                //   environment:
                //       JAVA_HOME
                //       PATH
                //       ANSIBLE_USER
                sh """
                    export JAVA_HOME=${JAVA_HOME}
                    export PATH=${JAVA_HOME}/bin:${PATH}
                    export ANSIBLE_USER=${env.USER}

                    cd ${PROJECT_ROOT}
                    bash ${BUILD_SCRIPT}
                """

                // Verify WAR was built
                sh """
                    if [ ! -s ${BUILD_DIR}/${WAR_NAME} ]; then
                        echo "ERROR: WAR file was NOT created!"
                        exit 1
                    fi
                """
            }
        }

        stage('Deploy Using Ansible') {
            steps {
                echo "=== Deploying via Ansible Playbook ==="

                sh """
                    ansible-playbook -i ${INVENTORY} ${DEPLOY_PLAY}
                """
            }
        }

        stage('Post-Deployment Health Check') {
            steps {
                script {
                    def url = "http://127.0.0.1:9090/petclinic/"
                    def retries = 12
                    def success = false

                    echo "=== Running health check ==="

                    for (int i = 0; i < retries; i++) {
                        def code = sh(
                            script: "curl -s -o /dev/null -w '%{http_code}' ${url}",
                            returnStdout: true
                        ).trim()

                        echo "HTTP Response: ${code}"

                        if (code == "200") {
                            success = true
                            break
                        }

                        sleep 5
                    }

                    if (!success) {
                        error("❌ PetClinic health check FAILED")
                    }
                }
            }
        }
    }

    post {
        success {
            echo "🎉 SUCCESS: PetClinic built + deployed successfully!"
        }
        failure {
            echo "❌ FAILURE — check Jenkins + Ansible logs."
        }
    }
}

pipeline {
    agent any

    stages {
        stage('Clone Repo') {
            steps {
                git 'https://github.com/spring-projects/spring-petclinic'
            }
        }
        stage('Build') {
            steps {
                sh './scripts/build_petclinic.sh'
            }
        }
        stage('Deploy to Tomcat') {
            steps {
                sh 'ansible-playbook deploy.yml'
            }
        }
    }
}

pipeline {

    agent any
    tools {
        maven "MAVEN3"
        jdk "OracleJDK11"
    }
    environment {
        registry="anmolk992/student-exp"
        registryCredentials = 'dockerhub'
    }

    stages {
        stage('BUILD') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
            post {
                success {
                    echo 'Now Archiving...'
                    archiveArtifacts artifacts: '**/target/*.jar'
                }
            }
        }

        stage('UNIT TEST') {
            steps {
                sh 'mvn test'
            }
        }

        stage('INTEGRATION TEST') {
            steps {
                sh 'mvn verify -DskipUnitTests'
            }
        }

        stage('CODE ANALYSIS WITH CHECKSTYLE') {
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
            post {
                success {
                    echo 'Generated Analysis Result'
                }
            }
        }

        stage('CODE ANALYSIS with SONARQUBE') {

            environment {
                scannerHome = tool 'sonar4.7'
            }

            steps {
                withSonarQubeEnv('sonar') {
                    sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=studentcrud \
                    -Dsonar.projectName=studentcrud \
                    -Dsonar.projectVersion=0.0.1-SNAPSHOT \
                    -Dsonar.sources=src/ \
                    -Dsonar.java.binaries=target/test-classes/com/example/studentcrud \
                    -Dsonar.junit.reportsPath=target/surefire-reports/ \
                    -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                    -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''

                }

                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build app image') {
            steps {
                script {
                    dockerImage = docker.build registry + ":v$BUILD_NUMBER"
                }
            }
        }

        stage('upload image') {
            steps {
                script {
                    docker.withRegistry('', registryCredentials) {
                        dockerImage.push("v$BUILD_NUMBER")
                        dockerImage.push("latest")
                    }
                }
            }
        }

        stage('remove unused docker image') {
            steps {
                sh "docker rmi $registry:v$BUILD_NUMBER"
            }
        }

        stage('Kubernetes Deploy') {
            agent { label 'KOPS' }
            steps {
                sh "helm upgrade --install --force student-stack helm/studentcharts --set appimage=${registry}:v${BUILD_NUMBER} --namespace prod"
            }
        }
    }
}
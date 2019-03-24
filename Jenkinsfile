pipeline {
  agent none
  environment {
    PROJECT_NAME = 'ehealth'
    INSTANCE_TYPE = 'n1-highcpu-16'
    RD = "b${UUID.randomUUID().toString()}"
    RD_CROP = "b${RD.take(14)}"
    NAME = "${RD.take(5)}"
  }
  stages {
    stage('Init') {
      agent {
        node { 
          label 'ehealth-build' 
          }
      }
      steps {
        sh 'docker version'
        sh 'echo $PROJECT_NAME'
      }
    }
  }
}

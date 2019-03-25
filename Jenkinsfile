pipeline {
  agent {
    node { 
      label 'ehealth-build' 
      }
  }
  environment {
    PROJECT_NAME = 'ehealth'
    MIX_ENV = 'test'
    DOCKER_NAMESPACE = 'edenlabllc'
    POSTGRES_VERSION = '9.6'
    POSTGRES_USER = 'postgres'
    POSTGRES_PASSWORD = 'postgres'
    POSTGRES_DB = 'postgres'
  }
  stages {
    stage('Init') {
      steps {
        sh '''
          sudo apt update && sudo apt install -y postgresql-client make build-essential jq;
          PGPASSWORD=postgres psql -U postgres -h localhost -c "create database ehealth";
          PGPASSWORD=postgres psql -U postgres -h localhost -c "create database prm_dev";
          PGPASSWORD=postgres psql -U postgres -h localhost -c "create database fraud_dev";
          PGPASSWORD=postgres psql -U postgres -h localhost -c "create database event_manager_dev";
        '''
        sh '''
        curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_v2/install-mongodb.sh -o install-mongodb.sh; 
        sudo sh ./install-mongodb.sh
        '''
      }
    }
    // stage('Test and build') {
    //   failFast true
    //   parallel {
    //     stage('Test') {
    //       steps {
    //         sh '''
    //           (curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/tests.sh -o tests.sh; bash ./tests.sh) || exit 1;
    //           cd apps/graphql && mix white_bread.run
    //           if [ "$?" -eq 0 ]; then echo "mix white_bread.run successfully completed" else echo "mix white_bread.run finished with errors, exited with 1" is_failed=1; fi;
    //           '''
    //       }
    //     }
    //     stage('Build ehealth-app') {
    //       environment {
    //         APPS = '[{"app":"ehealth","chart":"il","namespace":"il","deployment":"api","label":"api"}]'
    //       }
    //       steps {
    //         sh '''
    //           curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/build-container.sh -o build-container.sh;
    //           chmod +x ./build-container.sh;
    //           ./build-container.sh;
    //           rm build-container.sh
    //         '''
    //         sh '''
    //           curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/start-container.sh -o start-container.sh;
    //           chmod +x ./start-container.sh; 
    //           ./start-container.sh;
    //           rm start-container.sh
    //         '''
    //         // withCredentials(bindings: [usernamePassword(credentialsId: '8232c368-d5f5-4062-b1e0-20ec13b0d47b', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
    //         //   sh 'echo " ---- step: Push docker image ---- ";'
    //         //   sh 'curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/push-changes.sh -o push-changes.sh; sudo bash ./push-changes.sh'
    //         // }
    //         // sh 'curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/autodeploy.sh -o autodeploy.sh; bash ./autodeploy.sh'
    //       }
    //     }
    //   }
    // }
  }
}

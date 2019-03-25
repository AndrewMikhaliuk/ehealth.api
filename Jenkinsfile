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
          sudo docker run -d --name postgres -p 5432:5432 edenlabllc/alpine-postgre:pglogical-gis-1.1;
          sudo docker run -d --name mongo -p 27017:27017 edenlabllc/alpine-mongo:4.0.1-0;
          sudo docker run -d --name redis -p 6379:6379 redis:4-alpine3.9;
          sudo docker run -d --name kafkazookeeper -p 2181:2181 -p 9092:9092 edenlabllc/kafka-zookeeper:2.1.0;
          sleep 10;
          psql -U postgres -h localhost -c "create database ehealth";
          psql -U postgres -h localhost -c "create database prm_dev";
          psql -U postgres -h localhost -c "create database fraud_dev";
          psql -U postgres -h localhost -c "create database event_manager_dev";
          sudo docker exec -i kafkazookeeper /opt/kafka_2.12-2.1.0/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic merge_legal_entities;
          sudo docker exec -i kafkazookeeper /opt/kafka_2.12-2.1.0/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic deactivate_legal_entity_event;
          sudo docker exec -i kafkazookeeper /opt/kafka_2.12-2.1.0/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic edr_verification_events;
          mix local.hex --force;
          mix local.rebar --force;
          mix deps.get;
          mix deps.compile;
        '''
      }
    }
    stage('Test and build') {
      failFast true
      parallel {
        stage('Test') {
          steps {
            sh '''
              (curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/tests.sh -o tests.sh; bash ./tests.sh) || exit 1;
              cd apps/graphql && mix white_bread.run
              if [ "$?" -eq 0 ]; then echo "mix white_bread.run successfully completed" else echo "mix white_bread.run finished with errors, exited with 1" is_failed=1; fi;
              '''
          }
        }
        stage('Build ehealth-app') {
          environment {
            APPS = '[{"app":"ehealth","chart":"il","namespace":"il","deployment":"api","label":"api"}]'
          }
          steps {
            sh '''
              export PROJECT_DIR=${WORKSPACE};
              set -e
              echo "Current branch: ${GIT_BRANCH}";
              for row in $(echo "${APPS}" | jq -c '.[]'); do
                  APP_NAME=$(echo "${row}" | jq -r '.app')
                  DOCKERFILE=$(echo "${row}" | jq -r 'if .dockerfile then .dockerfile else "Dockerfile" end')

                  echo "[I] Building a Docker container for '$APP_NAME' application";
                  echo "docker build --tag \"${DOCKER_NAMESPACE}/$APP_NAME:$GIT_COMMIT\""
                  echo "    --file \"${PROJECT_DIR}/${DOCKERFILE}\""
                  echo "    --build-arg APP_NAME=$APP_NAME"
                  echo "    \"$PROJECT_DIR\""
                  
                  sudo docker build --tag "${DOCKER_NAMESPACE}/$APP_NAME:$GIT_COMMIT" \
                          --file "${PROJECT_DIR}/${DOCKERFILE}" \
                          --build-arg APP_NAME=$APP_NAME \
                          "$PROJECT_DIR";

                  echo
              done
            '''
            // sh 'curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/build-container.sh -o build-container.sh; sudo chmod 700 ./build-container.sh; sudo bash ./build-container.sh'
            // sh 'curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/start-container.sh -o start-container.sh; sudo chmod 700 ./start-container.sh; sudo bash ./start-container.sh'
            // withCredentials(bindings: [usernamePassword(credentialsId: '8232c368-d5f5-4062-b1e0-20ec13b0d47b', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
            //   sh 'echo " ---- step: Push docker image ---- ";'
            //   sh 'curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/push-changes.sh -o push-changes.sh; sudo bash ./push-changes.sh'
            // }
            // sh 'curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/autodeploy.sh -o autodeploy.sh; bash ./autodeploy.sh'
          }
        }
      }
    }
  }
}

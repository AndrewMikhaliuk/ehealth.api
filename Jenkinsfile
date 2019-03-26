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
    POSTGRES_VERSION = '10'
    POSTGRES_USER = 'postgres'
    POSTGRES_PASSWORD = 'postgres'
    POSTGRES_DB = 'postgres'
  }
  stages {
    stage('Init') {
      steps {
        sh 'cat /etc/hostname'
        sh 'sudo systemctl restart docker'
        sh '''
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
              (curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/tests.sh -o tests.sh; chmod +x ./tests.sh; ./tests.sh) || exit 1;
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
              curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/build-container.sh -o build-container.sh;
              chmod +x ./build-container.sh;
              ./build-container.sh;
            '''
            sh '''
              curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/start-container.sh -o start-container.sh;
              chmod +x ./start-container.sh; 
              ./start-container.sh;
            '''
            withCredentials(bindings: [usernamePassword(credentialsId: '8232c368-d5f5-4062-b1e0-20ec13b0d47b', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
              sh 'echo " ---- step: Push docker image ---- ";'
              sh '''
                  curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/push-changes.sh -o push-changes.sh;
                  chmod +x ./push-changes.sh;
                  sudo sh ./push-changes.sh
                '''
            }
          }
        }
        stage('Build casher-app') {
          environment {
            APPS = '[{"app":"casher","chart":"il","namespace":"il","deployment":"casher","label":"casher"}]'
          }
          steps {
            sh '''
              curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/build-container.sh -o build-container.sh;
              chmod +x ./build-container.sh;
              ./build-container.sh;  
            '''
            sh '''
              curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/start-container.sh -o start-container.sh;
              chmod +x ./start-container.sh; 
              ./start-container.sh;
            '''
            withCredentials(bindings: [usernamePassword(credentialsId: '8232c368-d5f5-4062-b1e0-20ec13b0d47b', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
              sh 'echo " ---- step: Push docker image ---- ";'
              sh '''
                  curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/push-changes.sh -o push-changes.sh;
                  chmod +x ./push-changes.sh;
                  sudo sh ./push-changes.sh
                '''
            }
          }
        }
        stage('Build graphql-app') {
          environment {
            APPS = '[{"app":"graphql","chart":"il","namespace":"il","deployment":"graphql","label":"graphql"}]'
            DB_MIGRATE = 'false'
          }
          steps {
            sh '''
              curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/build-container.sh -o build-container.sh;
              chmod +x ./build-container.sh;
              ./build-container.sh;
            '''
            sh '''
              curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/start-container.sh -o start-container.sh;
              chmod +x ./start-container.sh; 
              ./start-container.sh;
            '''
            withCredentials(bindings: [usernamePassword(credentialsId: '8232c368-d5f5-4062-b1e0-20ec13b0d47b', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
              sh 'echo " ---- step: Push docker image ---- ";'
              sh '''
                  curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/push-changes.sh -o push-changes.sh;
                  chmod +x ./push-changes.sh;
                  sudo sh ./push-changes.sh
                '''
            }
          }
        }
        stage('Build merge-legal-entities-consumer-app') {
          environment {
            APPS = '[{"app":"merge_legal_entities_consumer","chart":"il","namespace":"il","deployment":"merge-legal-entities-consumer","label":"merge-legal-entities-consumer"}]'
          }
          steps {
            sh '''
              curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/build-container.sh -o build-container.sh;
              chmod +x ./build-container.sh;
              ./build-container.sh;
              
            '''
            sh '''
              curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/start-container.sh -o start-container.sh;
              chmod +x ./start-container.sh; 
              ./start-container.sh;
            '''
            withCredentials(bindings: [usernamePassword(credentialsId: '8232c368-d5f5-4062-b1e0-20ec13b0d47b', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
              sh 'echo " ---- step: Push docker image ---- ";'
              sh '''
                  curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/push-changes.sh -o push-changes.sh;
                  chmod +x ./push-changes.sh;
                  sudo sh ./push-changes.sh
                '''
            }
          }
        }
        stage('Build deactivate-legal-entity-consumer-app') {
          environment {
            APPS = '[{"app":"deactivate_legal_entity_consumer","chart":"il","namespace":"il","deployment":"deactivate-legal-entity-consumer","label":"deactivate-legal-entity-consumer"}]'
          }
          steps {
            sh '''
              curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/build-container.sh -o build-container.sh;
              chmod +x ./build-container.sh;
              ./build-container.sh; 
            '''
            sh '''
              curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/start-container.sh -o start-container.sh;
              chmod +x ./start-container.sh; 
              ./start-container.sh;
            '''
            withCredentials(bindings: [usernamePassword(credentialsId: '8232c368-d5f5-4062-b1e0-20ec13b0d47b', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
              sh 'echo " ---- step: Push docker image ---- ";'
              sh '''
                  curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/push-changes.sh -o push-changes.sh;
                  chmod +x ./push-changes.sh;
                  sudo sh ./push-changes.sh
                '''
            }
          }
        }
        stage('Build edr-validations-consumer-app') {
          environment {
            APPS = '[{"app":"edr_validations_consumer","chart":"il","namespace":"il","deployment":"edr-validations-consumer","label":"edr-validations-consumer"}]'
          }
          steps {
            sh '''
              curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/build-container.sh -o build-container.sh;
              chmod +x ./build-container.sh;
              ./build-container.sh;
            '''
            sh '''
              curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/start-container.sh -o start-container.sh;
              chmod +x ./start-container.sh; 
              ./start-container.sh;
            '''
            withCredentials(bindings: [usernamePassword(credentialsId: '8232c368-d5f5-4062-b1e0-20ec13b0d47b', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
              sh 'echo " ---- step: Push docker image ---- ";'
              sh '''
                  curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins/push-changes.sh -o push-changes.sh;
                  chmod +x ./push-changes.sh;
                  sudo sh ./push-changes.sh
                '''
            }
          }
        }
        stage('Build ehealth-scheduler-app') {
          environment {
            APPS = '[{"app":"ehealth_scheduler","chart":"il","namespace":"il","deployment":"ehealth-scheduler","label":"ehealth-scheduler"}]'
          }
          steps {
            sh '''
              curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/build-container.sh -o build-container.sh;
              chmod +x ./build-container.sh;
              ./build-container.sh;
            '''
            sh '''
              curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/start-container.sh -o start-container.sh;
              chmod +x ./start-container.sh; 
              ./start-container.sh;
            '''
            withCredentials(bindings: [usernamePassword(credentialsId: '8232c368-d5f5-4062-b1e0-20ec13b0d47b', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
              sh 'echo " ---- step: Push docker image ---- ";'
              sh '''
                  curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/push-changes.sh -o push-changes.sh;
                  chmod +x ./push-changes.sh;
                  sudo sh ./push-changes.sh
                '''
            }
          }
        }
      }
    }
    stage('Deploy') {
      environment {
        APPS = '[{"app":"ehealth","chart":"il","namespace":"il","deployment":"api","label":"api"},{"app":"casher","chart":"il","namespace":"il","deployment":"casher","label":"casher"},{"app":"graphql","chart":"il","namespace":"il","deployment":"graphql","label":"graphql"},{"app":"merge_legal_entities_consumer","chart":"il","namespace":"il","deployment":"merge-legal-entities-consumer","label":"merge-legal-entities-consumer"},{"app":"deactivate_legal_entity_consumer","chart":"il","namespace":"il","deployment":"deactivate-legal-entity-consumer","label":"deactivate-legal-entity-consumer"},{"app":"edr_validations_consumer","chart":"il","namespace":"il","deployment":"edr-validations-consumer","label":"edr-validations-consumer"},{"app":"ehealth_scheduler","chart":"il","namespace":"il","deployment":"ehealth-scheduler","label":"ehealth-scheduler"}]'
      }
      steps {
        withCredentials([string(credentialsId: '86a8df0b-edef-418f-844a-cd1fa2cf813d', variable: 'GITHUB_TOKEN')]) {
          withCredentials([file(credentialsId: '05dde019-3c59-4eb0-b8af-d109bf55e86f', variable: 'GCLOUD_KEY')]) {
            sh '''
              curl -s https://raw.githubusercontent.com/edenlabllc/ci-utils/umbrella_jenkins_gce/autodeploy.sh -o autodeploy.sh;
              chmod +x ./autodeploy.sh;
              sudo sh ./autodeploy.sh
            '''
          }
        }
      }
    }
  }
}

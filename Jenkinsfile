pipeline {
  agent {
    node { 
      label 'ehealth-build' 
      }
  }
  environment {
    PROJECT_NAME = 'ehealth'
  }
  stages {
    stage('Init') {
      steps {
        sh '''sudo docker version;
          sudo apt update && sudo apt install -y postgresql-client;
          sudo docker run -d --name postgres -p 5432:5432 edenlabllc/alpine-postgre:pglogical-gis-1.1;
          sleep 20;
          psql -U postgres -h localhost -c "create database ehealth";
          psql -U postgres -h localhost -c "create database prm_dev";
          psql -U postgres -h localhost -c "create database fraud_dev";
          psql -U postgres -h localhost -c "create database event_manager_dev";
          sudo docker run -d --name mongo -p 27017:27017 edenlabllc/alpine-mongo:4.0.1-0;
          sudo docker run -d --name redis -p 6379:6379 redis:4-alpine3.9;
          sudo docker run -d --name kafkazookeeper -p 2181:2181 -p 9092:9092 edenlabllc/kafka-zookeeper:2.1.0;
          sleep 10;
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
  }
}

#!/bin/bash
#After starting all the components it is neeeded to import distances into mongoDB
cd ~/big_data
./resources/import_distances.sh

k_list=$(docker exec kafka "opt/kafka/bin/kafka-topics.sh --list --zookeeper 172.23.0.6:2181" | grep "flight_delay_classification_request" | wc -l)
if [  $k_list -eq  "1"]; then
    echo "Topic flight_delay_classification_request already created"
else
    echo "Created topic: flight_delay_classification_request"
    docker exec kafka /opt/kafka/bin/kafka-topics.sh --create --zookeeper 172.23.0.6:2181 --replication-factor 1 --partitions 1 --topic flight_delay_classification_request
fi
cd
#docker exec spark-submit spark-submit --master spark://spark-master:7077 --packages org.mongodb.spark:mongo-spark-connector_2.11:2.3.2,org.apache.spark:spark-sql-kafka-0-10_2.11:2.4.4 flight_prediction_2.11-0.1.jar
# to be tested today
docker exec spark-submit spark-submit --deploy-mode cluster --master spark://spark-master:7077 --packages org.mongodb.spark:mongo-spark-connector_2.11:2.3.2,org.apache.spark:spark-sql-kafka-0-10_2.11:2.4.4 /big_data/flight_prediction/target/scala-2.11/flight_prediction_2.11-0.1.jar
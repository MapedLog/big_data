# Agile_Data_Code_2

Code for [Agile Data Science 2.0](http://shop.oreilly.com/product/0636920051619.do), O'Reilly 2017. Now available at the [O'Reilly Store](http://shop.oreilly.com/product/0636920051619.do), on [Amazon](https://www.amazon.com/Agile-Data-Science-2-0-Applications/dp/1491960116) (in Paperback and Kindle) and on [O'Reilly Safari](https://www.safaribooksonline.com/library/view/agile-data-science/9781491960103/). Also available anywhere technical books are sold!

This is also the code for the [Realtime Predictive Analytics](http://datasyndrome.com/video) video course and [Introduction to PySpark](http://datasyndrome.com/training) live course!

Have problems? Please file an issue!


## Installation

The docker used in this project have the next requirements of Software
The following list includes in which image is installed and if it is needed in host machine:

 - Java 1.8 JDK : included in 
                              "bde2020/spark-submit:2.4.4-hadoop2.7", 
                              "bde2020/spark-master:2.4.4-hadoop2.7", 
                              "bde2020/spark-worker:2.4.4-hadoop2.7" docker images
 - Python 3.7 : included in 
                              "python:3.7" docker image
 - PIP 3 : included in 
                              "python:3.7" docker image
 - SBT : needed in            host machine
 - MongoDB : included in 
                              "mongo" docker image. 
    It is also needed in host machine, so you can import files into MongoDB.
 - Spark 2.4.4 : included in 
                              "bde2020/spark-submit:2.4.4-hadoop2.7", 
                              "bde2020/spark-master:2.4.4-hadoop2.7", 
                              "bde2020/spark-worker:2.4.4-hadoop2.7" docker images
 - Zookeeper 3.6.2 : included in 
                              "zookeeper:3.6.2" docker image
 - Kafka  2.12-2.3.0 : included in 
                              "wurstmeister/kafka:2.12-2.3.0" docker image
 - Nginx : included in 
                              "bunkerity/bunkerized-nginx" docker image
 
## Initial steps

To start using the tool, you just have to clone this repository and execute the "bdfi_container_init.sh" script. This will start all the containers needed for the project
```
cd ~
git clone https://github.com/MapedLog/big_data.git
mv big_data/bdfi_container_init.sh ~/
bdfi_container_init.sh
```

  ## Run Flight Predictor
  
  From this point, it can be done by executing the following script:
  
  ```
  cd ~
  mv big_data/bdfi_post_installer.sh ~/
  bdfi_post_installer.sh
 
 ```
  ### Run the import_distances.sh script
    
  ```
  ./resources/import_distances.sh
  ```
  Output:
  ```
  2019-10-01T17:06:46.957+0200	connected to: mongodb://localhost/
  2019-10-01T17:06:47.035+0200	4696 document(s) imported successfully. 0 document(s) failed to import.
  MongoDB shell version v4.2.0
  connecting to: mongodb://127.0.0.1:27017/agile_data_science?compressors=disabled&gssapiServiceName=mongodb
  Implicit session: session { "id" : UUID("9bda4bb6-5727-4e91-8855-71db2b818232") }
  MongoDB server version: 4.2.0
  {
  	"createdCollectionAutomatically" : false,
  	"numIndexesBefore" : 1,
  	"numIndexesAfter" : 2,
  	"ok" : 1
  }
  
  ```
  
  ### Open a new console and check if topic has already been created.
  
  ```
  docker exec kafka opt/kafka/bin/kafka-topics.sh --list --zookeeper 172.23.0.6:2181
  ```
  If a topic called "flight_delay_classification_request" is listed, then you don't have to run the following command:
  ```
  docker exec kafka /opt/kafka/bin/kafka-topics.sh --create --zookeeper 172.23.0.6:2181 --replication-factor 1 --partitions 1 --topic flight_delay_classification_request
  ```
  (Optional) You can open a new console with a consumer in order to see the messeges sent to that topic
  ```
 docker exec kafka /opt/kafka/bin/kafka-console-consumer.sh \
    --bootstrap-server localhost:9092 \
    --topic flight_delay_classification_request \
    --from-beginning
  ```
 
  ### This project is enabled to run spark-submit with the JAR generated with SBT.
   Open a new console
  ```
  docker exec spark-submit spark-submit --master spark://spark-master:7077 --packages org.mongodb.spark:mongo-spark-connector_2.11:2.3.2,org.apache.spark:spark-sql-kafka-0-10_2.11:2.4.4 /practica_big_data_2019/flight_prediction/target/scala-2.11/flight_prediction_2.11-0.1.jar
  ```
  Here, the script's functionality endes.
## Testing the full project
  Now, visit http://localhost:5000/flights/delays/predict_kafka and, for fun, open the JavaScript console. Enter a nonzero departure delay, an ISO-formatted date (I used 2016-12-25, which was in the future at the time I was writing this), a valid carrier code (use AA or DL if you don’t know one), an origin and destination (my favorite is ATL → SFO), and a valid flight number (e.g., 1519), and hit Submit. Watch the debug output in the JavaScript console as the client polls for data from the response endpoint at /flights/delays/predict/classify_realtime/response/.
  
  Quickly switch windows to your Spark console. Within 10 seconds, the length we’ve configured of a minibatch, you should see something like the following:
  
  ### Check the predictions records inserted in MongoDB
  Open a new console
  ```
   $ mongo --host 127.0.0.1:27017
   > use use agile_data_science;
   >db.flight_delay_classification_response.find();
  
  ```
  You must have a similar output as:
  
  ```
  { "_id" : ObjectId("5d8dcb105e8b5622696d6f2e"), "Origin" : "ATL", "DayOfWeek" : 6, "DayOfYear" : 360, "DayOfMonth" : 25, "Dest" : "SFO", "DepDelay" : 290, "Timestamp" : ISODate("2019-09-27T08:40:48.175Z"), "FlightDate" : ISODate("2016-12-24T23:00:00Z"), "Carrier" : "AA", "UUID" : "8e90da7e-63f5-45f9-8f3d-7d948120e5a2", "Distance" : 2139, "Route" : "ATL-SFO", "Prediction" : 3 }
  { "_id" : ObjectId("5d8dcba85e8b562d1d0f9cb8"), "Origin" : "ATL", "DayOfWeek" : 6, "DayOfYear" : 360, "DayOfMonth" : 25, "Dest" : "SFO", "DepDelay" : 291, "Timestamp" : ISODate("2019-09-27T08:43:20.222Z"), "FlightDate" : ISODate("2016-12-24T23:00:00Z"), "Carrier" : "AA", "UUID" : "d3e44ea5-d42c-4874-b5f7-e8a62b006176", "Distance" : 2139, "Route" : "ATL-SFO", "Prediction" : 3 }
  { "_id" : ObjectId("5d8dcbe05e8b562d1d0f9cba"), "Origin" : "ATL", "DayOfWeek" : 6, "DayOfYear" : 360, "DayOfMonth" : 25, "Dest" : "SFO", "DepDelay" : 5, "Timestamp" : ISODate("2019-09-27T08:44:16.432Z"), "FlightDate" : ISODate("2016-12-24T23:00:00Z"), "Carrier" : "AA", "UUID" : "a153dfb1-172d-4232-819c-8f3687af8600", "Distance" : 2139, "Route" : "ATL-SFO", "Prediction" : 1 }


```

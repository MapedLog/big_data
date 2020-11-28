#!/usr/bin


######################################## README #################################################
: 'This scripts is made to enable an operative and distributed data science architecture.
Before launching docker a few scripts have to be executed, so several data does not have to be download when docker is installed.
Data predictions are also be done before docker.
'
#Some variables that are going to be neeeded
#export SPARK_HOME=/opt/spark
#export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/opt/spark/bin:/opt/spark/sbin:/opt/spark/python
#export PYSPARK_PYTHON=/usr/bin/python3
#export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export PROJECT_HOME=~/big_data
#export PYTHONPATH=/opt/spark/python/lib/py4j-0.10.7-src.zip:/opt/spark/python

#source /home/euskart/.profile

############################################# DATA DOWNLOAD ##########################################
if [ -d "~/big_data/data" ]; then
    echo "Data directory already exists"
else
    echo "Data directory does not exists. Creating data"
    mkdir -p ~/big_data/data
fi

if [ -f "~/big_data/data/simple_flight_delay_features.jsonl.bz2" ] && [ -f "~/big_data/data/origin_dest_distances.jsonl" ] && [ -f "~/big_data/models/sklearn_vectorizer.pkl" ] && [-f "~/big_data/models/sklearn_regressor.pkl" ]; then
    echo "Data has already been download"
else
    echo "Downloading Data"   
    cd ~/big_data
    ./resources/download_data.sh 
    cd ~
fi
trained=$(ls -la ~/big_data/models | grep -e ".*.bin" | wc -l)
if [  $trained -eq "7" ]; then
    echo "Model alreeady trained"
else
    echo "Training model"
    cd ~/big_data
    pip3 install -r ~/big_data/requirements.txt   
    python3.7 resources/train_spark_mllib_model.py .
    cd ~
fi

#compile sbt
if [ -f "~/big_data/flight_prediction/target/scala-2.11/flight_prediction_2.11-0.1.jar" ]; then
    cd ~/big_data/flight_prediction
    sbt compile
    sbt package
    cd ~
fi

######################################## docker-compose ##############################################
## Initiate the bdfi network and all the containers
cd ~/big_data
docker-compose up


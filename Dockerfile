FROM python:3.7

COPY requirements.txt /

RUN pip install -r requirements.txt

# Add requirements, code
COPY big_data/resources/web/ /big_data/resources/web/
COPY big_data/models/ /big_data/models/
ENV PROJECT_HOME=/big_data
# Declare and expose service listening port
#EXPOSE 5000/tcp

# Declare entrypoint of that exposed service
CMD ["python3", "/big_data/resources/web/predict_flask.py"]
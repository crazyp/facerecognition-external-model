FROM alpine:edge

COPY Makefile /app/

RUN apk update \
    && apk add py3-pip py3-flask py3-numpy py3-gunicorn bzip2 cmake g++ make wget \
    && make -C /app/ download-models

RUN apk add dlib --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/
RUN apk add php82-common --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/
RUN apk add php82-pdlib --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/
COPY facerecognition-external-model.py /app/
COPY gunicorn_config.py /app/

WORKDIR /app/

EXPOSE 5000

ARG GUNICORN_WORKERS="1" \
    PORT="5000"
ENV GUNICORN_WORKERS="${GUNICORN_WORKERS}"\
    PORT="${PORT}"\
    API_KEY=some-super-secret-api-key\
    FLASK_APP=facerecognition-external-model.py

ENTRYPOINT ["gunicorn"  , "-c", "gunicorn_config.py", "facerecognition-external-model:app"]
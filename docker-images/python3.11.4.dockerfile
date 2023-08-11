# https://hub.docker.com/_/ubuntu
FROM ubuntu:mantic-20230801

# START PYTHON 
# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

RUN apt update && apt upgrade -y

RUN apt-get install -y python3 python3-pip htop


LABEL maintainer="Glaucio <glacsius@gmail.com>"

# START uvicorn-gunicorn-docker
# https://github.com/tiangolo/uvicorn-gunicorn-docker/blob/master/docker-images/python3.11.dockerfile


COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt --break-system-packages

COPY ./start.sh /start.sh
RUN chmod +x /start.sh

# get gunicorn_conf.py : https://github.com/tiangolo/uvicorn-gunicorn-docker/blob/master/docker-images/gunicorn_conf.py
COPY ./gunicorn_conf.py /gunicorn_conf.py

COPY ./app /app
WORKDIR /app/

ENV PYTHONPATH=/app

EXPOSE 80

# variaveis para auxiliar
ENV APP_NAME=
ENV DATABASE_USER=
ENV DATABASE_PASS=
ENV DATABASE_HOST=
ENV DATABASE_SYNTAX=
ENV ENVIRONMENT=prod


# Run the start script, it will check for an /app/prestart.sh script (e.g. for migrations)
# And then will start Gunicorn with Uvicorn
CMD ["/start.sh"]

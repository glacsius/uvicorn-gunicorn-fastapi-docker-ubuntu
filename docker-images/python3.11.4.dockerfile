# https://hub.docker.com/_/ubuntu
FROM ubuntu:latest

LABEL maintainer="Glaucio <glacsius@gmail.com>"

# START instalation PYTHON 3.11.4
# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

RUN apt update && apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev pkg-config -y

# config timezone to São Paulo, Brazil
RUN ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN echo "America/Sao_Paulo" > /etc/timezone

# configure o locale desejado (pt_BR.UTF-8) e descomente a linha no /etc/locale.gen, isso tbm faz o tzdata funinstalar sem pedir nada
RUN apt install -y locales
RUN locale-gen
RUN sed -i 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen && locale-gen

RUN apt-get install -y tzdata

RUN mkdir /tmp/install
WORKDIR /tmp/install

# download and extract Python source
RUN wget https://www.python.org/ftp/python/3.11.4/Python-3.11.4.tgz
RUN tar -xf Python-3.11.*.tgz
WORKDIR /tmp/install/Python-3.11.4

# Configure, compile e instale o Python
RUN ./configure --enable-optimizations
RUN make -j $(nproc)
RUN make altinstall
RUN python3.11 --version

# create a symlink for python3.11 as python3
RUN ln -s /usr/local/bin/python3.11 /usr/local/bin/python3
RUN python3 --version

# install pip
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python3.11 get-pip.py
RUN pip3.11 --version

# remove the download folder
WORKDIR /
RUN rm -rf /tmp/install

# END instalation PYTHON 

# another installations
RUN apt install -y htop git


# install server gunicon, uvicorn and fastapi
COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt
#RUN pip3 install --no-cache-dir -r /tmp/requirements.txt --break-system-packages

COPY ./start.sh /start.sh
RUN chmod +x /start.sh

# config file for gunicorn get from: https://github.com/tiangolo/uvicorn-gunicorn-docker/blob/master/docker-images/gunicorn_conf.py
COPY ./gunicorn_conf.py /gunicorn_conf.py

# copy initial app
COPY ./app /app
WORKDIR /app/

ENV PYTHONPATH=/app

EXPOSE 80

# variables for facility
ENV APP_NAME=
ENV DATABASE_USER=
ENV DATABASE_PASS=
ENV DATABASE_HOST=
ENV DATABASE_SYNTAX=
ENV ENVIRONMENT=prod
ENV SENDPULSE_USERID=
ENV SENDPULSE_TOKEN=
ENV SERVER_URL=
ENV TELEGRAM_TOKEN=
ENV TELEGRAM_CHAT_ID=
ENV AWS_ACCESS_KEY_ID=
ENV AWS_SECRET_ACCESS_KEY=


# after install, remove build-essential utilized for install python
RUN apt-get purge -y \
    build-essential \
    zlib1g-dev \
    libncurses5-dev \
    libgdbm-dev \
    libnss3-dev \
    libssl-dev \
    libreadline-dev \
    libffi-dev \
    libsqlite3-dev \
    libbz2-dev \
    pkg-config \
 && apt-get autoremove -y \
 && apt-get clean && rm -rf /var/lib/apt/lists/*


# Run the start script, it will check for an /app/prestart.sh script (e.g. for migrations)
# And then will start Gunicorn with Uvicorn
CMD ["/start.sh"]

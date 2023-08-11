# https://hub.docker.com/_/ubuntu
FROM ubuntu:latest

# START PYTHON 
# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8


RUN apt update && apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev pkg-config -y


# Configure o fuso horário para São Paulo, Brasil
RUN ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
RUN echo "America/Sao_Paulo" > /etc/timezone


# Configure o locale desejado (pt_BR.UTF-8) e descomente a linha no /etc/locale.gen
RUN apt install -y locales
RUN locale-gen
RUN sed -i 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/' /etc/locale.gen && locale-gen

RUN apt-get install -y tzdata

RUN mkdir /tmp/install
WORKDIR /tmp/install

RUN wget https://www.python.org/ftp/python/3.11.4/Python-3.11.4.tgz
RUN tar -xf Python-3.11.*.tgz
WORKDIR /tmp/install/Python-3.11.4

# Configure, compile e instale o Python
RUN ./configure --enable-optimizations
RUN make -j $(nproc)
RUN make altinstall
RUN python3.11 --version

# Crie um link simbólico para python3.11 como python3
RUN ln -s /usr/local/bin/python3.11 /usr/local/bin/python3
RUN python3 --version

# Install pip
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python3.11 get-pip.py
RUN pip3.11 --version

# Remova a pasta de download
WORKDIR /
RUN rm -rf /tmp/install

# outras 
RUN apt install -y htop git


# RUN apt update && apt upgrade -y && apt install -y software-properties-common

# RUN add-apt-repository -y ppa:deadsnakes/ppa

# RUN echo 'tzdata tzdata/Areas select America' | debconf-set-selections
# RUN echo 'tzdata tzdata/Zones/America select Sao_Paulo' | debconf-set-selections
# RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y tzdata

# RUN apt install -y python3.11 python3-pip htop



# Make Python 3.11.4 the default version
# To make the default version of Python 3.11.4, run this:

# sudo ln -s /usr/local/bin/python3.11 /usr/local/bin/python
# Test whether Python 3.11.4 is the default version:

# $ ls -al /usr/local/bin/python
# lrwxrwxrwx 1 root root 25 Jul  5 19:33 /usr/local/bin/python -> /usr/local/bin/python3.11
# python -VV





# RUN apt-get install -y python3 python3-pip htop


LABEL maintainer="Glaucio <glacsius@gmail.com>"

# START uvicorn-gunicorn-docker
# https://github.com/tiangolo/uvicorn-gunicorn-docker/blob/master/docker-images/python3.11.dockerfile


COPY requirements.txt /tmp/requirements.txt
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt
#RUN pip3 install --no-cache-dir -r /tmp/requirements.txt --break-system-packages

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




#depois q está instalado, pode-se remover o build-essential
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


## Links `Dockerfile`

* [`python3.11.4`, `latest` _(Dockerfile)_](https://github.com/glacsius/uvicorn-gunicorn-fastapi-docker-ubuntu/blob/master/docker-images/python3.11.4.dockerfile)


* [`python3.11.6`, `latest` _(Dockerfile)_](https://github.com/glacsius/uvicorn-gunicorn-fastapi-docker-ubuntu/blob/master/docker-images/python3.11.6.dockerfile)


## Origem
Fork de https://hub.docker.com/r/tiangolo/uvicorn-gunicorn-fastapi

A imagem do tiangolo é excelente e usa imagem docker do debian. Meu servidor docker parou de supportar o debian, então esse é um fork usando ubuntu.

Imagem para uso próprio e foi removido as versões anteriores ao python 3.11.

originalmente, o dockerfile do tiangolo/uvicorn-gunicorn-fastapi usa 

```dockerfile
FROM tiangolo/uvicorn-gunicorn:python3.11
```

e esse usa:
 

    |- FROM tiangolo/uvicorn-gunicorn:python3.11
        |- FROM python:3.11
            |- FROM buildpack-deps:bookworm
                |- FROM buildpack-deps:bookworm-scm
                    |- FROM buildpack-deps:bookworm-curl
                        |- FROM debian:bookworm


## Detalhes
Essa imagem usa FROM ubuntu:latest, configura e instala o python 3.11 via fontes, e depois instala o uvicorn e gunicorn.
Está usando o mesmo arquivo de configuração do guinicorn do tiangolo: https://github.com/tiangolo/uvicorn-gunicorn-docker/blob/master/docker-images/gunicorn_conf.py


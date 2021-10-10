ARG version=18.04

FROM ubuntu:${version}

ARG branch
ARG gitURL

LABEL com.gitURL=${gitURL} \
  com.gitBranch=${branch} \
  com.createdBy="Venkhat Balaji" \
  com.mailID="venkhatbalaji1607@gmail.com"

ENV user=venkhat

RUN set -x && \
  apt update -y && \
  apt install -y sudo wget vim tar zip python3-flask python3-pip mysql-server libmysqlclient-dev && \
  pip3 install flask-mysqldb && \
  useradd -m ${user}

WORKDIR /home/${user}

USER ${user}

COPY dockerFlask.zip .

RUN unzip dockerFlask.zip

EXPOSE 5500

ENTRYPOINT ["python3", "docker/dockerFlask/main.py"]
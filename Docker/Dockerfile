#Assigning default version
ARG version=18.04
FROM ubuntu:${version} AS project

ARG branch=master
ARG version
RUN echo ${branch} && echo ${version}

WORKDIR /tmp

RUN set -x && \
  apt update -y && \
  apt install -y git wget && \
  git clone https://github.com/VenkhatBalaji95/flaskProject.git -b ${branch}

FROM ubuntu:${version}

ARG version
RUN echo ${version}

LABEL gitURL="https://github.com/VenkhatBalaji95/flaskProject.git" \
  gitBranch=${branch} \
  createdBy="Venkhat Balaji" \
  mailID="venkhatbalaji1607@gmail.com"

WORKDIR /project

RUN set -x && \
  apt update -y && \
  apt install -y sudo git wget tar zip python3-flask python3-pip mysql-server libmysqlclient-dev && \
  pip3 install flask-mysqldb

ENV user=venkhat

RUN useradd -m ${user}

WORKDIR /home/${user}

USER ${user}

COPY --from=project --chown=${user} /tmp/flaskProject/pythonFlask .

EXPOSE 5500

ENTRYPOINT ["python3", "main.py"]

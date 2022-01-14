FROM ubuntu:latest

RUN set -x && \
  apt update -y && \
  apt install -y python3

WORKDIR /kubernetes/opt

COPY jobs.py .

ENTRYPOINT ["python3", "jobs.py"]
CMD ["-n venkhat"]

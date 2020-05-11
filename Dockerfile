FROM python:3-slim

LABEL maintainer="robert@opsani.com"
LABEL description="A servo for opsani.com optimization"
LABEL plugins="servo-k8s, servo-vegeta"
LABEL version="0.1.1"
WORKDIR /servo

ARG VEGETA_VER
ENV VEGETA_VER=v12.8.1
ADD  https://storage.googleapis.com/kubernetes-release/release/v1.16.2/bin/linux/amd64/kubectl /usr/local/bin/

# Install dependencies
RUN apt update && apt -y install procps tcpdump curl wget
RUN pip3 install requests PyYAML python-dateutil

RUN mkdir -p measure.d

# Install servo
ADD https://raw.githubusercontent.com/opsani/servo/master/servo \
    https://raw.githubusercontent.com/opsani/servo/master/adjust.py \
    https://raw.githubusercontent.com/opsani/servo/master/measure.py \
    https://raw.githubusercontent.com/opsani/servo-k8s/master/adjust \
    https://raw.githubusercontent.com/opsani/servo-vegeta/master/measure \
    /servo/

RUN curl -sL https://github.com/tsenart/vegeta/releases/download/v12.8.3/vegeta-12.8.3-linux-amd64.tar.gz| tar xfz - -C /usr/local/bin/
RUN chmod a+rwx /servo/adjust /servo/measure /servo/servo /usr/local/bin/kubectl /usr/local/bin/vegeta
RUN chmod a+r /servo/adjust.py /servo/measure.py

ENV PYTHONUNBUFFERED=1

ENTRYPOINT [ "python3", "servo" ]

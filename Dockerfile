FROM python:3.7-slim

LABEL maintainer="support@opsani.com"
LABEL description="A servo for opsani.com optimization"
LABEL plugins="servo-prom, servo-k8s, servo-vegeta"
LABEL version="1.0.0"
LABEL k8s-version="v1.18.2"
LABEL vegeta-version="v12.8.3"

WORKDIR /servo

ARG VEGETA_VER
ENV VEGETA_VER=v12.8.3
ADD  https://storage.googleapis.com/kubernetes-release/release/v1.18.2/bin/linux/amd64/kubectl /usr/local/bin/

# Install dependencies
RUN apt update && apt -y install procps tcpdump curl wget
RUN pip3 install requests PyYAML python-dateutil

RUN mkdir -p measure.d

ADD https://raw.githubusercontent.com/opsani/servo-prom/master/measure measure.d/measure-prom
ADD https://raw.githubusercontent.com/opsani/servo-vegeta/master/measure measure.d/measure-vegeta
ADD https://raw.githubusercontent.com/opsani/servo/master/measure.py measure.d/

# Install servo
ADD https://raw.githubusercontent.com/opsani/servo/master/servo \
    https://raw.githubusercontent.com/opsani/servo/master/adjust.py \
    https://raw.githubusercontent.com/opsani/servo/master/measure.py \
    https://raw.githubusercontent.com/opsani/servo-k8s/master/adjust \
    https://raw.githubusercontent.com/opsani/servo-magg/master/measure \
    /servo/

RUN curl -sL https://github.com/tsenart/vegeta/releases/download/v12.8.3/vegeta-12.8.3-linux-amd64.tar.gz| tar xfz - -C /usr/local/bin/
RUN chmod a+rwx /servo/adjust /servo/measure /servo/servo /usr/local/bin/kubectl /usr/local/bin/vegeta
RUN chmod a+r /servo/adjust.py /servo/measure.py measure.d/measure.py
RUN chmod a+rwx /servo/measure.d/measure-prom /servo/measure.d/measure-vegeta

ENV PYTHONUNBUFFERED=1

ENTRYPOINT [ "python3", "servo" ]

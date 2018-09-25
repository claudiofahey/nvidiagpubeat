#
# Build Container
#

FROM golang:1.7

MAINTAINER Claudio Fahey <Claudio.Fahey@dell.com>

RUN \
    (curl https://bootstrap.pypa.io/get-pip.py | python) && \
    pip install virtualenv && \
    (curl https://glide.sh/get | sh)

RUN \
    git clone https://github.com/elastic/beats ${GOPATH}/src/github.com/elastic/beats && \
    cd ${GOPATH}/src/github.com/elastic/beats && \
    git checkout v5.5.3

COPY . src/github.com/deepujain/nvidiagpubeat

ENV DOCKERVERSION=17.12.1-ce

RUN \
    curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKERVERSION}.tgz && \
    tar xzvf docker-${DOCKERVERSION}.tgz --strip 1 -C /usr/local/bin docker/docker && \
    rm docker-${DOCKERVERSION}.tgz


ENV PROJECT_DIR=${GOPATH}/src/github.com/deepujain/nvidiagpubeat

RUN \
    cd ${PROJECT_DIR} && \
    make setup && \
    make

#
# Execution Container
#

FROM nvcr.io/nvidia/tensorflow:18.07-py3

MAINTAINER Claudio Fahey <Claudio.Fahey@dell.com>

WORKDIR /root/

COPY --from=0 /go/src/github.com/deepujain/nvidiagpubeat/nvidiagpubeat* /root/

CMD /root/nvidiagpubeat

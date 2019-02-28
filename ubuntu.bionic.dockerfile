# Ubuntu Dockerfile
#
# https://github.com/dockerfile/ubuntu
#

# Pull base image.
FROM ubuntu:bionic

# Building tools and dependencies
RUN rm -rf /var/lib/apt/lists/*
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y git cmake build-essential curl software-properties-common apt-transport-https libevent-dev libssl-dev cmake
RUN curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | bash
RUN apt-get update
RUN apt-get install -y libparc-dev libasio-dev

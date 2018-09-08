FROM ruby:2.3.3
MAINTAINER nguyenquangminh0711@gmail.com

RUN apt-get update
RUN apt-get install -y flex bison

WORKDIR /app
COPY . /app

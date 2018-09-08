FROM ruby:2.3.3
MAINTAINER nguyenquangminh0711@gmail.com

RUN apt-get update
RUN apt-get install -y flex bison

RUN gem update bundler

WORKDIR /app
COPY . /app

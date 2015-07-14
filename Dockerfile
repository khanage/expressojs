FROM ubuntu:14.04

ENV DEBIAN_FRONTEND noninteractive
ENV LANG=C.UTF-8

RUN apt-get update && \
    apt-get install -y \
            openjdk-7-jre-headless \
            nodejs-legacy \
            git \
            npm && \
    npm install -g \
      bower \
      closure-compiler \
      gulp \
      purescript@0.6.10 \
      pulp@3.2.2 && \
   apt-get clean && \
   rm -rf /var/lib/apt/lists/

WORKDIR /app

ADD package.json /app/package.json
RUN npm install

ADD bower.json /app/bower.json
RUN bower install --allow-root --config.interactive=false

ADD ./gulpfile.js /app/gulpfile.js

ADD ./.git /app/.git

ADD ./test /app/test
ADD ./src /app/src

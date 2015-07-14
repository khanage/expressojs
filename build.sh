#!/bin/bash

echo "Running gulp build"

echo "Building docker image"
hash boot2docker &> /dev/null
if [ $? -eq 1 ]; then
    $(boot2docker shellinit)
fi
docker build -t ryvus/expressojs --rm .

echo "Running gulp build => index.js"
docker run --rm ryvus/expressojs 1> index.js

echo "Done"

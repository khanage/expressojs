#!/bin/bash

echo "Building image"

hash boot2docker &> /dev/null
if [ $? -eq 1 ]; then
    echo "Found boot2docker, running shellinit"
    $(boot2docker shellinit)
fi

docker build -t ryvus/expressojs --rm .

echo "Built"

echo "Run gulp once attached"
echo "exit to quit."

docker run -it --rm ryvus/expressojs

#!/bin/bash

docker stop rh8_x86
docker rm rh8_x86

docker run -it -d --name="rh8_x86" -v /home/images:/home/images 269749ad516c /bin/bash

docker exec -it rh8_x86 /bin/bash

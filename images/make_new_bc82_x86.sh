#!/bin/bash

docker stop bc82_x86
docker rm bc82_x86

docker run -it -d --name="bc82_x86" -v /home/images:/home/images 9c1fbb9a99a5 /bin/bash

docker exec -it bc82_x86 /bin/bash

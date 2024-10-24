#!/bin/bash

docker stop euler_x86
docker rm euler_x86

docker run -it -d --name="euler_x86" -v /home/images:/home/images 6d0dd638bd55 /bin/bash

docker exec -it euler_x86 /bin/bash

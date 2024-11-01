#!/bin/bash

docker stop el7_x86
docker rm el7_x86

docker run -it -d --name="el7_x86" -v /home/images:/home/images eeb6ee3f44bd /bin/bash

docker exec -it el7_x86 /bin/bash

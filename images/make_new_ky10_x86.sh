#!/bin/bash

docker stop ky10_x86
docker rm ky10_x86

docker run -it -d --name="ky10_x86" -v /home/images:/home/images 210ea0890576 /bin/bash

docker exec -it ky10_x86 /bin/bash

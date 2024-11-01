#!/bin/bash

docker stop euler_x86
docker rm euler_x86

docker run -it -d --name="euler_x86" -v /home/images:/home/images a0213c9a6ecb /bin/bash

docker exec -it euler_x86 "/home/images/dev/images/reset_tmout.sh"
docker stop euler_x86
docker start euler_x86
docker exec -it euler_x86 "/bin/bash"
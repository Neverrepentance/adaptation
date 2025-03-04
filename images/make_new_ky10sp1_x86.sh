#!/bin/bash

docker stop ky10sp1_x86
docker rm ky10sp1_x86

docker run -it -d --name="ky10sp1_x86" -v /home/images:/home/images 1c30db4bdc1c /bin/bash

docker exec -it ky10sp1_x86 /bin/bash

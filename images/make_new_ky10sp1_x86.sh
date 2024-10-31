#!/bin/bash

docker stop ky10_x86
docker rm ky10_x86

docker run -it -d --name="ky10_x86" -v /home/images:/home/images 5c56a917f1ea /bin/bash

docker exec -it ky10_x86 /bin/bash

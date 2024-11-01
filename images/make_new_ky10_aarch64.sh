#!/bin/bash

docker stop ky10_arm64
docker rm ky10_arm64

docker run --rm --privileged multiarch/qemu-user-static:register

docker run -it -d --name="ky10_arm64" -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static -v /home/images:/home/images d3a169ee4cdd /bin/bash

docker exec -it ky10_arm64 /bin/bash


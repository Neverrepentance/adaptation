#!/bin/bash

docker stop euler_arm64
docker rm euler_arm64

docker run --rm --privileged multiarch/qemu-user-static:register

docker run -it -d --name="euler_arm64" -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static -v /home/images:/home/images 8823cff74d8a /bin/bash

docker exec -it euler_arm64 /bin/bash


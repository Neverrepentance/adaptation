#!/bin/bash

docker stop euler_arm64
docker rm euler_arm64

docker run --rm --privileged multiarch/qemu-user-static:register

docker run -it -d --name="euler_arm64" -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static -v /home/images:/home/images 26ceb9210faf /bin/bash

docker exec -it euler_arm64 "/home/images/dev/images/reset_tmout.sh"
docker stop euler_arm64
docker start euler_arm64
docker exec -it euler_arm64 "/bin/bash"



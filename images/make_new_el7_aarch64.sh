#!/bin/bash

docker stop el7_arm64
docker rm el7_arm64

docker run --rm --privileged multiarch/qemu-user-static:register

docker run -it -d --name="el7_arm64" -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static -v /home/images:/home/images c9a1fdca3387 /bin/bash

docker exec -it el7_arm64 /bin/bash


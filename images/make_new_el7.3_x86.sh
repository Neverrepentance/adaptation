#!/bin/bash

docker stop el73_x86
docker rm el73_x86

docker run -it -d --name="el73_x86" -v /home/images:/home/images c5d48e81b986 /bin/bash

docker exec -it el73_x86 /bin/bash

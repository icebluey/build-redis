#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
set -e
systemctl start docker
sleep 5
echo
cat /proc/cpuinfo
echo
if [ "$(cat /proc/cpuinfo | grep -i '^processor' | wc -l)" -gt 1 ]; then
    docker run --cpus="$(cat /proc/cpuinfo | grep -i '^processor' | wc -l).0" --rm --name ub2204 -itd ubuntu:22.04 bash
else
    docker run --rm --name ub2204 -itd ubuntu:22.04 bash
fi
sleep 2
docker exec ub2204 apt update -y
#docker exec ub2204 apt upgrade -fy
docker exec ub2204 apt install -y bash vim wget ca-certificates curl
docker exec ub2204 /bin/ln -svf bash /bin/sh
docker exec ub2204 /bin/bash -c '/bin/rm -fr /tmp/*'
docker cp ub2204 ub2204:/home/
docker exec ub2204 /bin/bash /home/ub2204/.preinstall_ub2204
docker exec ub2204 /bin/bash /home/ub2204/build-redis82.sh
mkdir -p /tmp/_output_assets
docker cp ub2204:/tmp/_output /tmp/_output_assets/
exit


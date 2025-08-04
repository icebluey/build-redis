#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
set -e
cd "$(dirname "$0")"
systemctl start docker
sleep 5
echo
cat /proc/cpuinfo
echo
if [ "$(cat /proc/cpuinfo | grep -i '^processor' | wc -l)" -gt 1 ]; then
    docker run --cpus="$(cat /proc/cpuinfo | grep -i '^processor' | wc -l).0" --rm --name ky10 -itd macrosan/kylin:v10-sp3-2403 bash
else
    docker run --rm --name ky10 -itd macrosan/kylin:v10-sp3-2403 bash
fi
sleep 2
docker exec ky10 yum clean all
docker exec ky10 yum makecache
docker exec ky10 yum install -y wget bash
docker exec ky10 /bin/bash -c 'ln -svf bash /bin/sh'
docker exec ky10 /bin/bash -c 'rm -fr /tmp/*'
docker cp ky10 ky10:/home/
docker exec ky10 /bin/bash /home/ky10/.preinstall_ky10
docker exec ky10 /bin/bash /home/ky10/build-redis82.sh
mkdir -p /tmp/_output_assets
docker cp ky10:/tmp/_output /tmp/_output_assets/
exit


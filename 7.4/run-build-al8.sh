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
    #docker run --cpus="$(cat /proc/cpuinfo | grep -i '^processor' | wc -l).0" --rm --name al8 -itd almalinux:8 bash
    docker run --cpus="$(cat /proc/cpuinfo | grep -i '^processor' | wc -l).0" --rm --name al8 -itd quay.io/almalinuxorg/almalinux:8 bash
else
    #docker run --rm --name al8 -itd almalinux:8 bash
    docker run --rm --name al8 -itd quay.io/almalinuxorg/almalinux:8 bash
fi
sleep 2
docker exec al8 yum clean all
docker exec al8 yum makecache
docker exec al8 yum install -y wget bash
docker exec al8 /bin/bash -c 'ln -svf bash /bin/sh'
docker exec al8 /bin/bash -c 'rm -fr /tmp/*'
docker cp al8 al8:/home/
#docker exec al8 /bin/bash /home/al8/install-kernel.sh
docker exec al8 /bin/bash /home/al8/.preinstall_al8
docker exec al8 /bin/bash /home/al8/build-redis74.sh
mkdir -p /tmp/_output_assets
docker cp al8:/tmp/_output /tmp/_output_assets/
exit


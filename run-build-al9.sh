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
    #docker run --cpus="$(cat /proc/cpuinfo | grep -i '^processor' | wc -l).0" --rm --name al9 -itd almalinux:9 bash
    docker run --cpus="$(cat /proc/cpuinfo | grep -i '^processor' | wc -l).0" --rm --name al9 -itd quay.io/almalinuxorg/almalinux:9 bash
else
    #docker run --rm --name al9 -itd almalinux:9 bash
    docker run --rm --name al9 -itd quay.io/almalinuxorg/almalinux:9 bash
fi
sleep 2
docker exec al9 yum clean all
docker exec al9 yum makecache
docker exec al9 yum install -y wget bash
docker exec al9 /bin/bash -c 'ln -svf bash /bin/sh'
docker exec al9 /bin/bash -c 'rm -fr /tmp/*'
docker cp al9 al9:/home/
docker exec al9 /bin/bash /home/al9/install-kernel.sh
docker exec al9 /bin/bash /home/al9/.preinstall_al9
docker exec al9 /bin/bash /home/al9/build-redis80.sh
mkdir -p /tmp/_output_assets
docker cp al9:/tmp/_output /tmp/_output_assets/
exit


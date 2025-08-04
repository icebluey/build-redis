#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
umask 022
/sbin/ldconfig
dnf makecache
dnf install -y wget tar gzip xz bzip2 gawk sed grep
dnf install -y kernel kernel-core kernel-devel kernel-headers
set -e
_tmp_dir="$(mktemp -d)"
cd "${_tmp_dir}"

TAGS=$(wget -qO- 'https://github.com/icebluey/kernel/tags' | \
       grep -i 'href="/.*/releases/tag/' | \
       sed 's|"|\n|g' | \
       grep -i '/releases/tag/' | \
       sed 's|.*/tag/||g' | \
       sort -V | uniq | sort -r)
CONTENT=''
ALL_CONTENT=''
for tag in $TAGS; do
    URL="https://github.com/icebluey/kernel/releases/expanded_assets/${tag}"
    CONTENT=$(wget -qO- "$URL")
    ALL_CONTENT+="$CONTENT\n"
done
_release_time=$(echo "${ALL_CONTENT}" | grep -i 'kernel-core.*el9' | sed 's|"|\n|g' | grep -i '/kernel/releases/download/.*/kernel-core.*el9' | sed -e 's|.*download/||g' -e 's|/kernel.*||g' | sort -V | uniq | tail -n 1)
_release_ver=$(echo "${ALL_CONTENT}" | grep -i 'kernel-core.*el9' | sed 's|"|\n|g' | grep -i '/kernel/releases/download/.*/kernel-core.*el9' | sed -e 's|.*kernel-core-||g' -e 's|\.el9.*||g' | sort -V | uniq | tail -n 1)
wget "https://github.com/icebluey/kernel/releases/download/${_release_time}/kernel-${_release_ver}.el9.x86_64-repos.tar.gz"
CONTENT=''
ALL_CONTENT=''

tar -xof kernel-*.tar*
sleep 1
rm -f kernel-*.tar*
rm -fr /.repos/kernel
install -m 0755 -d /.repos
mv -v kernel-* /.repos/kernel
cd /tmp
rm -fr "${_tmp_dir}"
#
cat << EOF > /etc/yum.repos.d/kernel-6.12.repo
[el-9-for-x86_64-kernel-rpms]
baseurl = file:///.repos/kernel
name = Enterprise Linux 9 for x86_64 - Kernel (RPMs)
enabled = 1
gpgcheck = 0
proxy=_none_
EOF
#
dnf makecache
dnf upgrade -y kernel kernel-core kernel-devel kernel-headers
exit


#!/bin/bash
set -euxo pipefail

echo "fastestmirror=1" >>/etc/dnf/dnf.conf
echo "max_parallel_downloads=20" >>/etc/dnf/dnf.conf
dnf -qy install git mock rpm-build rpmdevtools

FEDORA_RELEASE=39
SPEC=/src/*.spec

rpmdev-spectool -R -g $SPEC
rpmbuild -bs $SPEC | tee /tmp/srpm-name.txt
SRPM_NAME=$(grep Wrote /tmp/srpm-name.txt | awk '{print $2}')
mock -r /etc/mock/fedora-${FEDORA_RELEASE}-x86_64.cfg --postinstall $SRPM_NAME
rpmlint /var/lib/mock/fedora-${FEDORA_RELEASE}-x86_64/result/*.rpm

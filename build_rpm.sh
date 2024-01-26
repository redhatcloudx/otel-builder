#!/bin/bash
set -euxo pipefail

FEDORA_RELEASE=39
SPEC=/src/golang-github-redhatcloudx-otel-builder.spec

# Set up packages.
echo "fastestmirror=1" >>/etc/dnf/dnf.conf
echo "max_parallel_downloads=20" >>/etc/dnf/dnf.conf
dnf -qy install git mock rpm-build rpmdevtools

# Set the right commit SHA in the spec file.
pushd /src
CURRENT_COMMIT=$(git rev-parse HEAD)
sed -i "s/CURRENT_COMMIT_GOES_HERE/${CURRENT_COMMIT}/" $SPEC
popd

# Build the RPM.
rpmdev-spectool -R -g $SPEC
rpmbuild -bs $SPEC | tee /tmp/srpm-name.txt
SRPM_NAME=$(grep Wrote /tmp/srpm-name.txt | awk '{print $2}')
mock -r /etc/mock/fedora-${FEDORA_RELEASE}-x86_64.cfg --postinstall $SRPM_NAME
rpmlint /var/lib/mock/fedora-${FEDORA_RELEASE}-x86_64/result/*.rpm

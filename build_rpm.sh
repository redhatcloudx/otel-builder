#!/bin/bash
set -euxo pipefail

FEDORA_RELEASE=39
SPEC=golang-github-redhatcloudx-otel-builder.spec

pushd /src

# Set the right commit SHA in the spec file.
CURRENT_COMMIT=$(git rev-parse HEAD)
sed -i "s/CURRENT_COMMIT_GOES_HERE/${CURRENT_COMMIT}/" $SPEC

# Build the RPM.
rpmdev-spectool -R -g $SPEC
rpmbuild -bs $SPEC | tee /tmp/srpm-name.txt
SRPM_NAME=$(grep Wrote /tmp/srpm-name.txt | awk '{print $2}')
mock --quiet --root /etc/mock/fedora-${FEDORA_RELEASE}-x86_64.cfg --postinstall $SRPM_NAME
rpmlint /var/lib/mock/fedora-${FEDORA_RELEASE}-x86_64/result/*.rpm

#!/bin/sh

# File autogenerated by mix horizon.init (source: build.sh.eex)
#
# Calls `build_script-my_app.sh` on the target host.
# The build_script is expected to be on the host.
# The script is located in the build folder for each `bin_path` and release.
#
# Example
#
#    ./bin/build-my_app.sh
#
#

set -e

export SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

BUILD_HOST_SSH="${BUILD_HOST_SSH:-}"
BUILD_SCRIPT="${SCRIPT_DIR}/build_script-cloud.sh"

ssh ${BUILD_HOST_SSH} 'export PATH=$(cat .path):$PATH; (cd /usr/local/opt/cloud/build; MIX_ENV=prod ./bin/build_script-cloud.sh)'
version=$(ssh ${BUILD_HOST_SSH} "cat /usr/local/cloud/releases/start_erl.data")

if [ -z "$version" ]; then
  echo "No release version found from '$version'."
  exit 1
else
  version=$(echo "$version" | cut -d ' ' -f 2)
  mkdir -p .releases

  # Copy the release tarball to the releases directory
  scp -q ${BUILD_HOST_SSH}:"/usr/local/cloud/cloud-${version}.tar.gz" .releases
  echo "cloud-${version}.tar.gz" > ".releases/cloud.data"
fi

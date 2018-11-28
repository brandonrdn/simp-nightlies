#!/bin/sh

TYPE="${1}"
shift
if [ "${1}" != "" ] ; then
    distribution="${1}"
else
    distribution="puppet5"
fi

# Set global dir variables
export source_dir="$(pwd)"
export VERSION=${VERSION:=nightly-$(timedatectl | head -n 1 | awk '{print $4}')}
export BUILDDIR="${source_dir}/rubygem-simp-metadata/build"
export BINARIESDIR="${source_dir}/binaries"
export EL_VERSION=${EL_VERSION:=el7}
export PLATFORM=${PLATFORM}

# Copy ssh and licence keys
echo "${LICENSE_KEY}" > ./license.key
echo "${SSH_KEY}" > ./ssh_key
chmod 700 ./ssh_key
export SIMP_METADATA_SSHKEY="$(pwd)/ssh_key"
export GIT_SSH="$(pwd)/git_ssh_wrapper.sh"

git clone https://github.com/brandonrdn/rubygem-simp-metadata

# Purge global dirs
rm -rf "${BINARIESDIR}"
if [ ! -d "${BINARIESDIR}" ];then
mkdir -p "${BINARIESDIR}"
fi

git clone https://github.com/brandonrdn/rubygem-simp-metadata
cd rubygem-simp-metadata
bundle install
export RUBYGEM_DIR="$(pwd)"

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
export BUILDDIR="${source_dir}/iso_builds"
export BINARIESDIR="${source_dir}/binaries"
export EL_VERSION=${EL_VERSION:=el7}
export PLATFORM=${PLATFORM}

# Copy ssh and licence keys
echo "${LICENSE_KEY}" > ./license.key
echo "${SSH_KEY}" > ./ssh_key
chmod 700 ./ssh_key
export SIMP_METADATA_SSHKEY="$(pwd)/ssh_key"
export GIT_SSH="$(pwd)/git_ssh_wrapper.sh"

# Purge global dirs
rm -rf "${BUILDDIR}"
if [ ! -d "${BUILDDIR}" ];then
mkdir "${BUILDDIR}"
mkdir "${BUILDDIR}"
fi
rm -rf "${BINARIESDIR}"
if [ ! -d "${BINARIESDIR}" ];then
mkdir -p "${BINARIESDIR}"
fi

# Install simp-metadata gem
export METADATA_VERSION=${METADATA_VERSION:=0.4.3}
if [ ! -f simp-metadata-${METADATA_VERSION}.gem ];then
wget https://download.simp-project.com/simp/assets/rubygem-simp-metadata/simp-metadata-${METADATA_VERSION}.gem
fi
gem install --local --pre simp-metadata-${METADATA_VERSION}.gem

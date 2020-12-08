#!/bin/bash

set -ex
export TRAVIS_BUILD_DIR=$(pwd)
export TRAVIS_BRANCH=$DRONE_BRANCH
export VCS_COMMIT_ID=$DRONE_COMMIT
export GIT_COMMIT=$DRONE_COMMIT
export DRONE_CURRENT_BUILD_DIR=$(pwd)
export PATH=~/.local/bin:$PATH

echo '==================================> BEFORE_INSTALL'

. .drone/before-install.sh

echo '==================================> INSTALL'

BOOST_BRANCH=develop && [ "$TRAVIS_BRANCH" == "master" ] && BOOST_BRANCH=master || true
cd ..
git clone -b $BOOST_BRANCH --depth 1 https://github.com/boostorg/boost.git boost-root
cd boost-root
git submodule update --init tools/build
git submodule update --init libs/config
git submodule update --init tools/boostdep
cp -r $TRAVIS_BUILD_DIR/* libs/array
python tools/boostdep/depinst/depinst.py array
./bootstrap.sh
./b2 headers

echo '==================================> COMPILE'

echo "using $TOOLSET : : $COMPILER ;" > ~/user-config.jam
./b2 -j 3 libs/array/test toolset=$TOOLSET cxxstd=$CXXSTD

echo '==================================> AFTER_SUCCESS'

cd $DRONE_CURRENT_BUILD_DIR
. .drone/after-success.sh

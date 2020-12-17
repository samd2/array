#!/bin/bash

set -ex
export TRAVIS_BUILD_DIR=$(pwd)
export TRAVIS_BRANCH=$DRONE_BRANCH
export TRAVIS_OS_NAME=${DRONE_JOB_OS_NAME:-linux}
export VCS_COMMIT_ID=$DRONE_COMMIT
export GIT_COMMIT=$DRONE_COMMIT
export DRONE_CURRENT_BUILD_DIR=$(pwd)
export PATH=~/.local/bin:$PATH

echo '==================================> BEFORE_INSTALL'

. .drone/before-install.sh

echo '==================================> INSTALL'

BOOST_BRANCH=develop && [ "$TRAVIS_BRANCH" == "master" ] && BOOST_BRANCH=master || true
git clone -b $BOOST_BRANCH --depth 1 https://github.com/boostorg/assert.git ../assert
git clone -b $BOOST_BRANCH --depth 1 https://github.com/boostorg/config.git ../config
git clone -b $BOOST_BRANCH --depth 1 https://github.com/boostorg/core.git ../core
git clone -b $BOOST_BRANCH --depth 1 https://github.com/boostorg/static_assert.git ../static_assert
git clone -b $BOOST_BRANCH --depth 1 https://github.com/boostorg/throw_exception.git ../throw_exception

echo '==================================> BEFORE_SCRIPT'

. $DRONE_CURRENT_BUILD_DIR/.drone/before-script.sh

echo '==================================> SCRIPT'

mkdir __build__ && cd __build__
cmake ../test/test_cmake
cmake --build .

echo '==================================> AFTER_SUCCESS'

. $DRONE_CURRENT_BUILD_DIR/.drone/after-success.sh

#!/bin/bash
set -ex

check_env(){
  #Checking python-pip software status. If failed, reinstall it.
  set +e
  sudo pip --version
  CHECK_PIP_SUDO=$?

  pip --version
  CHECK_PIP_USER=$?
  set -e

  #Check command result, if failed, reinstall the pip
  if [ ${CHECK_PIP_SUDO} -ne 0 ] || [ ${CHECK_PIP_USER} -ne 0 ]; then
    echo "Reinstall pip"
    sudo python -m pip uninstall -y pip
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    sudo python get-pip.py pip
    rm get-pip.py
    hash -r
  fi

  # Clean environment
  sudo docker rm -f `sudo docker ps | grep compass | cut -f1 -d' '` || true
}

build_compass(){

  echo "Clone compass4nfv"
  git clone -b CompassinAkrainoIEC https://github.com/iecedge/compass4nfv.git

  cd compass4nfv

  COMPASS_WORK_DIR=$WORKSPACE/../compass-work

  mkdir -p $COMPASS_WORK_DIR
  ln -snf $COMPASS_WORK_DIR work

  ./build.sh
}

check_env

# Build compass
build_compass

# Fix permissions so we can archive log files before pushing to Nexus
sudo chown $(id -u):$(id -g) -R "${WORKSPACE}"

exit 0

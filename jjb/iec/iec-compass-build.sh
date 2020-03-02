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
}

checkout_arm64(){
  VERSION="dcc6d07"
  git checkout ${VERSION}
  sed -i 's:opnfv/:cyb70289/:' build/build-aarch64.yaml
}

check_env

echo "begin build compass"
git clone https://github.com/opnfv/compass4nfv.git

cd compass4nfv

if [ "$(uname -m)" = 'aarch64' ]; then
  echo "Checkout compass4nfv to Arm64 version"
  checkout_arm64
fi

COMPASS_WORK_DIR=$WORKSPACE/../compass-work

mkdir -p $COMPASS_WORK_DIR
ln -s $COMPASS_WORK_DIR work

sudo docker rm -f `sudo docker ps | grep compass | cut -f1 -d' '` || true

curl -sL http://people.linaro.org/~yibo.cai/compass/compass4nfv-arm64-fixup.sh | bash || true

./build.sh

# Fix permissions so we can archive log files before pushing to Nexus
sudo chown $(id -u):$(id -g) -R "${WORKSPACE}"

exit 0

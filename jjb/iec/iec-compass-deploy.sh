#!/bin/bash
set -e

cd compass4nfv

# Create 3 virtual machine
echo -e "  - name: host3\n    roles:\n      - kube_node" >> deploy/conf/vm_environment/k8-nosdn-nofeature-noha.yml
# Remove useless code
sed -i "33,90d" deploy/adapters/ansible/kubernetes/ansible-kubernetes.yml

export ADAPTER_OS_PATTERN='(?i)ubuntu-16.04.*arm.*'
export OS_VERSION="xenial"
export KUBERNETES_VERSION="v1.13.0"

export DHA="deploy/conf/vm_environment/k8-nosdn-nofeature-noha.yml"
export NETWORK="deploy/conf/vm_environment/network.yml"
export VIRT_NUMBER=3 VIRT_CPUS=4 VIRT_MEM=12288 VIRT_DISK=50G

./deploy.sh

echo "Compass Deploy successful"
exit 0

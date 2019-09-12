#!/bin/bash

#######################################
# all masters settings below must be same
#######################################


# master01 ip address
export K8SHA_IP1=10.10.5.70

# master02 ip address
export K8SHA_IP2=10.10.5.71

# master03 ip address
export K8SHA_IP3=10.10.5.72


# master01 hostname
export K8SHA_HOSTNAME1=kube-master1

# master02 hostname
export K8SHA_HOSTNAME2=kube-master2

# master03 hostname
export K8SHA_HOSTNAME3=kube-master3

#etcd tocken:
export ETCD_TOKEN=9489bf67bdfe1b3ae077d6fd9e7efefd

#etcd version
export ETCD_VERSION="v3.3.10"


##############################
# please do not modify anything below
##############################

# config etcd cluster
if [[ $1 == 'etcd' ]] || [[ $1 == 'all' ]]; then
  touch /etc/etcd.env
  echo PEER_NAME=$(hostname) > /etc/etcd.env
  echo PRIVATE_IP=$(hostname -i) >> /etc/etcd.env
  sed \
  -e "s/K8SHA_IPLOCAL/$(hostname -i)/g" \
  -e "s/K8SHA_IP1/$K8SHA_IP1/g" \
  -e "s/K8SHA_IP2/$K8SHA_IP2/g" \
  -e "s/K8SHA_IP3/$K8SHA_IP3/g" \
  -e "s/K8SHA_ETCDNAME/$(hostname)/g" \
  -e "s/K8SHA_HOSTNAME1/$K8SHA_HOSTNAME1/g" \
  -e "s/K8SHA_HOSTNAME2/$K8SHA_HOSTNAME2/g" \
  -e "s/K8SHA_HOSTNAME3/$K8SHA_HOSTNAME3/g" \
  etcd/etcd.service.tmpl > /etc/systemd/system/etcd.service
  echo etcd config copy to /etc/systemd/system/etcd.service
  cat /etc/systemd/system/etcd.service
fi

if [[ $1 == 'docker' ]]; then
  if [[ $(hostname) == kube-master1 ]]; then
  etcd_host=etcd1
  elif [[ $(hostname) == kube-master2 ]]; then
  etcd_host=etcd2
  elif [[ $(hostname) == kube-master3 ]]; then
  etcd_host=etcd3
fi
  sed \
  -e "s/IPLOCAL/$(hostname -i)/g" \
  -e "s/HOSTNAME/$etcd_host/g" \
  -e "s/K8SHA_IP1/$K8SHA_IP1/g" \
  -e "s/K8SHA_IP2/$K8SHA_IP2/g" \
  -e "s/K8SHA_IP3/$K8SHA_IP3/g" \
  etcd-docker/docker-compose.yaml.tpl > etcd-docker/docker-compose.yaml
  echo docker-compose file create
  cat etcd-docker/docker-compose.yaml
fi

if [[ $1 == 'kubeadm' ]] || [[ $1 == 'all' ]]; then
  sed \
  -e "s/IPLOCAL/$(hostname -i)/g" \
  -e "s/HOSTNAME/$etcd_host/g" \
  -e "s/K8SHA_IP1/$K8SHA_IP1/g" \
  -e "s/K8SHA_IP2/$K8SHA_IP2/g" \
  -e "s/K8SHA_IP3/$K8SHA_IP3/g" \
  kubeadmin/kubeadm-init.yaml.tmpl > kubeadmin/kubeadm-init.yaml
  echo kubeadm-init file create
  cat kubeadmin/kubeadm-init.yaml
fi

if [[ $1 == 'haproxy' ]] || [[ $1 == 'all' ]]; then
  sed \
  -e "s/IPLOCAL/$(hostname -i)/g" \
  -e "s/K8SHA_IP1/$K8SHA_IP1/g" \
  -e "s/K8SHA_IP2/$K8SHA_IP2/g" \
  -e "s/K8SHA_IP3/$K8SHA_IP3/g" \
  haproxy/haproxy.cfg.tmpl > /etc/haproxy/haproxy.cfg
  systemctl restart haproxy.service
fi

if [[ $1 == 'ingress' ]] || [[ $1 == 'all' ]]; then
  sed \
  -e "s/K8SHA_IP1/$K8SHA_IP1/g" \
  -e "s/K8SHA_IP2/$K8SHA_IP2/g" \
  -e "s/K8SHA_IP3/$K8SHA_IP3/g" \
  ingress/service-nodeport.yaml.tmpl > ingress/service-nodeport.yaml
  cat ingress/service-nodeport.yaml
fi

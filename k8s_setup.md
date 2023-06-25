# Rename hostname and map private IPs 
sudo hostnamectl set-hostname newhostname
update /etc/hosts for ip address and hostname for all three servers

# Setup networking

cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat << EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# Install containerd 
sudo apt-get update && sudo apt install containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.tml

# Install kubernetes
sudo systemctl restart containerd

sudo swapoff -a
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add

cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

sudo apt-get update
sudo apt-get install -y kubelet=1.24.0-00 kubeadm=1.24.0-00 kubectl=1.24.0-00

# Don't automatically upgrade kubernetes packages
sudo apt-mark hold kubelet kubeadm kubectl

# Install in kube control server, vm size has to have two CPUs
kubeadm reset
sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.24.0 

# Initialize k8s control-plane

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Control plane will still be in notready state
kubeadm reset # required if previous config needs to be wiped 
https://my.f5.com/manage/s/article/K000087252 #recreate $HOME/.kube/config

# Install networking plugin
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml

# Configure cgroup driver 
https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/configure-cgroup-driver/

# Create join token for worker nodes
kubeadm token create --print-join-command

#restart kubelet and containerd
sudo systemctl restart kubelet
sudo systemctl restart containerd
sudo systemctl status kubelet
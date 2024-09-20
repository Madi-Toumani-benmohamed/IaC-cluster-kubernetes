#!/bin/bash

# Définit une variable d'environnement pour éviter les invites interactives lors des installations apt
UBUNTU_FRONTEND=noninteractive

# Affiche un message indiquant la mise à jour du système
echo "Petite mise a jour du system avant tout"

# Met à jour la liste des paquets et met à jour tous les paquets installés
sudo apt-get update -y && sudo apt-get upgrade -y

# Affiche un message indiquant la préparation du noyau pour Kubernetes
echo "Je m occupe de preparer le noyau maintenant"

# Désactive l'échange (swap) car Kubernetes nécessite que le swap soit désactivé pour fonctionner correctement
sudo swapoff -a

# Remonte tous les systèmes de fichiers listés dans /etc/fstab
sudo mount -a

# Charge les modules nécessaires pour le réseau et le stockage avec containerd
sudo tee /etc/modules-load.d/containerd.conf << EOF
overlay
br_netfilter
EOF

# Active les modules overlay et br_netfilter pour le noyau
sudo modprobe overlay
sudo modprobe br_netfilter

# Configure les paramètres du noyau pour permettre la gestion des paquets réseau par iptables
sudo tee /etc/sysctl.d/kubernetes.conf << EOF
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

# Applique les paramètres du noyau configurés précédemment
sudo sysctl --system

# Affiche un message pour indiquer que le noyau est correctement configuré
echo "noyau OK"
echo "Je m occupe de containerd maintenant!"

# Installe les dépendances nécessaires pour containerd
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Télécharge la clé GPG pour le dépôt Docker et l'ajoute aux clés de confiance
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg

# Ajoute le dépôt Docker stable pour Ubuntu
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Met à jour la liste des paquets pour inclure le dépôt Docker
sudo apt update

# Installe containerd, qui est le runtime de conteneur utilisé par Kubernetes
sudo apt install -y containerd.io

# Crée un fichier de configuration par défaut pour containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1

# Modifie la configuration de containerd pour utiliser systemd comme gestionnaire de groupes de contrôle (cgroups)
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

# Redémarre et active le service containerd pour qu'il se lance au démarrage
sudo systemctl restart containerd
sudo systemctl enable containerd

# Affiche un message indiquant que containerd est prêt
echo " containerd c est ok"
echo " plus que les dependances lie a k8s"

# Ajoute le dépôt officiel Kubernetes pour installer kubeadm, kubelet, et kubectl
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Télécharge et ajoute la clé GPG pour le dépôt Kubernetes
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg 

# Télécharge et ajoute la clé GPG de Google Cloud pour les paquets Kubernetes
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Met à jour la liste des paquets pour inclure le dépôt Kubernetes
sudo apt update -y

# Installe kubelet, kubeadm, et kubectl
sudo apt install -y kubelet kubeadm kubectl

# Marque les paquets kubelet, kubeadm et kubectl pour qu'ils ne soient pas mis à jour automatiquement
sudo apt-mark hold kubelet kubeadm kubectl

# Affiche un message indiquant que l'installation de Kubernetes est terminée
echo "tout est pret [OK]"

# Rappelle à l'utilisateur de configurer le fichier hosts et de vérifier le nom d'hôte de la machine
echo " n oublies pas de configurer ton fichiers hosts"
echo " change ton hostname s il est pas approprie avec hostnamectl set-hostname"

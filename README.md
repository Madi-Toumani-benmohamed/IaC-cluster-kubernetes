Voici un exemple de fichier `README.md` pour votre dépôt Git, qui inclut toutes les informations que vous avez demandées :

```markdown
# Script d'Installation Kubernetes

Ce dépôt contient un script Bash pour installer Kubernetes sur des serveurs Ubuntu. Ce script configure et installe les prérequis nécessaires à Kubernetes, tels que `containerd` et les dépendances réseau.

## Utilisation

Le script est à exécuter sur **chaque serveur**, qu'il s'agisse du **nœud master** ou des **nœuds workers**. Une fois le script lancé, vous pourrez initialiser votre cluster Kubernetes en suivant les étapes ci-dessous.

### 1. Lancer le script d'installation

Exécutez le script d'installation sur chaque serveur (master et worker) pour configurer Kubernetes :

```bash
./install-kubernetes.sh
```

### 2. Initialisation du Cluster

Une fois le script exécuté sur le serveur qui sera le **nœud master**, vous devez initialiser le cluster Kubernetes en exécutant la commande suivante :

```bash
sudo kubeadm init \
  --pod-network-cidr=$ip_fixe \
  --control-plane-endpoint= $ip_fixe \
  --apiserver-advertise-address= $ip_fixe
```

- Remplacez `$ip_fixe` par l'adresse IP fixe de votre serveur.

### 3. Configurer l'accès au cluster

Pour commencer à utiliser le cluster Kubernetes sur le nœud master, configurez `kubectl` en exécutant les commandes suivantes :

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Ces commandes permettent à `kubectl` d'utiliser la configuration générée par `kubeadm` pour interagir avec le cluster.

### 4. Déployer un réseau pour les Pods

Kubernetes nécessite un plugin réseau pour gérer la communication entre les pods. Nous recommandons d'utiliser **Calico** pour ce déploiement. Pour l'installer, récupérez le fichier de manifeste YAML de Calico :

```bash
curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml -O
```

#### Modification de la configuration réseau

Ouvrez le fichier `calico.yaml` et cherchez la ligne contenant `CALICO_IPV4POOL_CIDR`. Modifiez-la en définissant l'adresse réseau avec son CIDR que vous souhaitez utiliser pour les pods dans votre cluster. Par exemple :

```yaml
- name: CALICO_IPV4POOL_CIDR
  value: "192.168.0.0/16"
```

Cela configure l'adresse réseau pour les pods dans votre cluster Kubernetes.

### 5. Accéder aux Manifests Kubernetes

Tous les fichiers manifests pour les composants Kubernetes du nœud master, tels que le plan de contrôle et les autres composants critiques, se trouvent dans le répertoire suivant :

```bash
/etc/kubernetes/manifests/
```

Ces fichiers peuvent être utiles pour déboguer ou ajuster la configuration des différents composants Kubernetes sur le nœud master.

## Débogage réseau

Pour déboguer des problèmes réseau, vous pouvez consulter et modifier les différents manifests présents dans `/etc/kubernetes/manifests/`.

## Conclusion

Ce script simplifie l'installation de Kubernetes sur des serveurs Ubuntu et vous permet de configurer rapidement un cluster Kubernetes avec un réseau Calico. N'oubliez pas d'ajuster les adresses réseau en fonction de votre infrastructure lors de l'installation du réseau pour les pods.
```

### Ce fichier `README.md` contient :
- Les instructions pour lancer le script sur chaque serveur (master et workers).
- La commande pour initialiser le cluster Kubernetes sur le nœud master.
- Les étapes pour configurer `kubectl` après l'initialisation du cluster.
- Le processus pour installer le réseau Calico et modifier son CIDR pour correspondre à l'architecture réseau du cluster.
- Les informations sur l'emplacement des manifests Kubernetes pour faciliter le débogage.

Vous pouvez ajouter ce fichier à votre dépôt Git afin de fournir une documentation claire pour les utilisateurs.

### Task 0: Install a ubuntu 16.04 server 64-bit

#### Answer record

create two vms in CDS cloud, so i didn't install the virtualBox and start the ubuntu system again in the windows. 

server001: 148.153.90.227

server002: 148.153.54.132

### Task 1: Update system

ssh to guest machine from host machine ($ ssh user@localhost -p 2222) and update the system to the latest

https://help.ubuntu.com/16.04/serverguide/apt.html

upgrade the kernel to the 16.04 latest

#### Answer record

```reStructuredText
### step1: Update Ubuntu Repository and Upgrade all Packages
apt update
apt upgrade -y
sudo reboot  
sudo apt list --upgradeable 

### Step 2 - Checking the Active Kernel Version
uname -msr
Linux 4.4.0-142-generic x86_64

### Step 3 - Install New Kernel Version
mkdir /root/5.12 
cd /root/5.12 
wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.12-rc3/amd64/linux-headers-5.12.0-051200rc3-generic_5.12.0-051200rc3.202103142231_amd64.deb
wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.12-rc3/amd64/linux-headers-5.12.0-051200rc3_5.12.0-051200rc3.202103142231_all.deb
wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.12-rc3/amd64/linux-image-unsigned-5.12.0-051200rc3-generic_5.12.0-051200rc3.202103142231_amd64.deb
wget https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.12-rc3/amd64/linux-modules-5.12.0-051200rc3-generic_5.12.0-051200rc3.202103142231_amd64.deb

dpkg -i *.deb 
update-grub 
reboot 
uname -msr 
output>
Linux 5.12.0-051200rc3-generic x86_64
```

### Task 2: install gitlab-ce version in the host

https://about.gitlab.com/install/#ubuntu?version=ce

Expect output: Gitlab is up and running at http://127.0.0.1 (no tls or FQDN required)

Access it from host machine http://127.0.0.1:8080

#### Answer record

```reStructuredText
### step1 - Install and configure the necessary dependencies 
sudo apt-get install -y curl openssh-server ca-certificates tzdata perl

### step2 - Add the GitLab package repository and install the package
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash

sudo EXTERNAL_URL="http://gitlab-demo.example.com" apt-get install gitlab-ce

### step3 - Login 
add "148.153.90.227 gitlab-demo.example.com" in Win HOSTS.
open http://gitlab-demo.example.com in Chrome and reset password 

### step4 - Remind 
the code will be accessed in http://gitlab-demo.example.com 
```

Trouble:

```powershell
root@server001:~# sudo apt-get install -y curl openssh-server ca-certificates tzdata perl
Reading package lists... Done
Building dependency tree
Reading state information... Done
ca-certificates is already the newest version (20210119~16.04.1).
curl is already the newest version (7.47.0-1ubuntu2.18).
openssh-server is already the newest version (1:7.2p2-4ubuntu2.10).
perl is already the newest version (5.22.1-9ubuntu0.9).
tzdata is already the newest version (2021a-0ubuntu0.16.04).
You might want to run 'apt-get -f install' to correct these:
The following packages have unmet dependencies:
 linux-headers-5.12.0-051200rc3-generic : Depends: libssl1.1 (>= 1.1.0) but it is not installable
E: Unmet dependencies. Try 'apt-get -f install' with no packages (or specify a solution).

### run "apt-get -f install" then reinstall packages, resolved 
```

### Task 3: create a demo group/project in gitlab

named demo/go-web-hello-world (demo is group name, go-web-hello-world is project name).

Use golang to build a hello world web app (listen to 8081 port) and check-in the code to mainline.

https://golang.org/<br>
https://gowebexamples.com/hello-world/

Expect source code at http://127.0.0.1:8080/demo/go-web-hello-world

#### Answer record

```reStructuredText
### step1 - install go and config GOPATH  
wget https://dl.google.com/go/go1.13.5.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.13.5.linux-amd64.tar.gz

vim /etc/profile
export PATH=$PATH:/usr/local/go/bin
export GOPATH=/root/go
source /etc/profile

### step2 - create project and coding 
mkdir /root/go 
mkdir -p /root/go/src
mkdir -p /root/go/bin
mkdir -p /root/go/pkg

mkdir -p /root/go/src/go-web-hello-world
vi /root/go/src/go-web-hello-world/run.go
--------
package main

import (
    "fmt"
    "net/http"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Go Web Hello World!", r.URL.Path)
    })

    http.ListenAndServe(":8081", nil)
}
---------

### step3 - go build and run, verify  
cd /root/go/src/go-web-hello-world && go build run.go
go run run.go 

curl 148.153.54.132:8081 
output> 
Go Web Hello World! 

### step4 - config git ssh key and setup demo repository 
ssh-keygen -o 
cat  ~/.ssh/id_rsa.pub
copy the ssh key into the gitlab 

git config --global user.email "jizhi@163.com"
git config --global user.name "jizhi.sui"

### step5 - git init and push code
cd /root/go/src/go-web-hello-world
git init
git remote add origin git@gitlab-demo.example.com:root/go-web-hello-world.git
git add .
git commit -m "Initial code"
git push -u origin master
git log --graph 
output>
commit da429c194822155ddafd2a041251efbbdddf4401
Author: jizhi.sui <jizhi@163.com>
Date:   Tue Mar 16 00:02:56 2021 +0800

    Initial code
```

Finally, you can access to the code in http://gitlab-demo.example.com/root/go-web-hello-world, please config the "148.153.54.132 gitlab-demo.example.com" in your Win HOSTS. 

### Task 4: build the app and expose ($ go run) the service to 8081 port

Expect output: 

```
curl http://127.0.0.1:8081
Go Web Hello World!
```

#### Answer record

```reStructuredText
### step 1 - go run in server002
cd /root/go/src/go-web-hello-world 
go run run.go 

### step 2 - curl server002(148.153.54.132:8081) 
curl 148.153.54.132:8081
output> 
Go Web Hello World!
```

### Task 5: install docker

https://docs.docker.com/install/linux/docker-ce/ubuntu/

#### Answer record

```reStructuredText
### step1 - set up the repository 
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
### step2 - install docker 
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

### step3 - verify 
docker --version 
output>
Docker version 20.10.5, build 55c4c88
```

### Task 6: run the app in container

build a docker image ($ docker build) for the web app and run that in a container ($ docker run), expose the service to 8082 (-p)

https://docs.docker.com/engine/reference/commandline/build/

Check in the Dockerfile into gitlab

Expect output:

```
curl http://127.0.0.1:8082
Go Web Hello World!
```

#### Answer record

```powershell
cd /root/go/src/go-web-hello-world

### step1 - dockerfile 
FROM golang:alpine as build
WORKDIR /root/go/src/demo/go-web-hello-world
ADD . .
RUN CGO_ENABLED=1 GOOS=linux go build -o run

FROM alpine:3.6
COPY --from=build /root/go/src/demo/go-web-hello-world/run .
CMD ["./run"]


### step2 - build image 
docker build -t go-web-hello-world:v1.0 .
docker image ls 
output>
REPOSITORY           TAG       IMAGE ID       CREATED          SIZE
go-web-hello-world   v1.0      b045fb3e611c   4 minutes ago    10.2MB
<none>               <none>    7717592a1307   4 minutes ago    319MB
<none>               <none>    26bb15923f32   10 minutes ago   313MB
golang               alpine    19b59f022241   4 days ago       301MB
alpine               3.6       43773d1dba76   2 years ago      4.03MB

### step3 - start docker 
docker run --name demo -d -p 8082:8081 go-web-hello-world:v1.0

### step4 - verify 
curl 148.153.54.132:8082
output>
Go Web Hello World!
```

### Task 7: push image to dockerhub

tag the docker image using your_dockerhub_id/go-web-hello-world:v0.1 and push it to docker hub (https://hub.docker.com/)

Expect output: https://hub.docker.com/repository/docker/your_dockerhub_id/go-web-hello-world

#### Answer record

```reStructuredText
### step1 - tag image 
docker tag go-web-hello-world:v1.0 yichuankaorou/go-web-hello-world:v1.0

### step2 - login dockerHub 
docker login 

### step3 - push image 
docker push yichuankaorou/go-web-hello-world:v1.0

### Remind: 
You can find the image in https://hub.docker.com/repository/docker/yichuankaorou/go-web-hello-world 
```

### Task 8: document the procedure in a MarkDown file

create a README.md file in the gitlab repo and add the technical procedure above (0-7) in this file

#### Answer record

```reStructuredText
### step 1 - add 0-7 technical procedure in README.md 

### step 2 - git push 
cd /root/go/src/go-web-hello-world
git add .
git commit -m "add README.md"
git push  origin  master

### step 3 - verify 
git log 
output> 
commit d870aa24ce9ed3268b09b277959ab01d38920de9
Author: jizhi.sui <jizhi@163.com>
Date:   Tue Mar 16 11:06:30 2021 +0800

    add README.md
    
### Remind, you can accesss to the README.md in http://gitlab-demo.example.com/root/go-web-hello-world, please add "148.153.54.132 gitlab-demo.example.com" in your Win HOSTS.
```

-----------------------------------

### Task 9: install a single node Kubernetes cluster using kubeadm

https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/

Check in the admin.conf file into the gitlab repo

#### Answer record

```reStructuredText
### step 1 - switch off swap 
swapoff -a

### step 2 - config repository 
vi /etc/apt/sources.list
# 系统安装源
deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted
deb http://mirrors.aliyun.com/ubuntu/ xenial universe
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates universe
deb http://mirrors.aliyun.com/ubuntu/ xenial multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
# kubeadm及kubernetes组件安装源
deb https://mirrors.aliyun.com/kubernetes/apt kubernetes-xenial main

apt-get update 

### step 3 - install kubeadm and kubectl and kubelet 
apt-get install -y kubelet kubeadm kubectl --allow-unauthenticated

kubeadm version 
output>
kubeadm version: &version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.4", GitCommit:"e87da0bd6e03ec3fea7933c4b5263d151aafd07c", GitTreeState:"clean", BuildDate:"2021-02-18T16:09:38Z", GoVersion:"go1.15.8", Compiler:"gc", Platform:"linux/amd64"}

kubectl version 
output>
Client Version: version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.4", GitCommit:"e87da0bd6e03ec3fea7933c4b5263d151aafd07c", GitTreeState:"clean", BuildDate:"2021-02-18T16:12:00Z", GoVersion:"go1.15.8", Compiler:"gc", Platform:"linux/amd64"}
The connection to the server localhost:8080 was refused - did you specify the right host or port?

kubelet version
output>
Kubernetes v1.20.4

### step 4 - kubeadm init (api-server is in server002-148.153.54.132)
kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=148.153.54.132 
output>
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 148.153.54.132:6443 --token 5mzbr1.livmi15uny2ybf3w \
    --discovery-token-ca-cert-hash sha256:a7d20a1b95233206296e197d198c3aad74040893a3d1e2980ee851262844da3a
    
### step 4 - config kubectl 
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

### step 5 - install flannel 
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

### step 6 - verify 
kubectl get nodes 
output> 
NAME        STATUS   ROLES                  AGE     VERSION
server002   Ready    control-plane,master   5m59s   v1.20.4

### step 7 - checkin the admin.conf into gitlab (as before git push steps)
```

### Task 10: deploy the hello world container

in the kubernetes above and expose the service to nodePort 31080

Expect output:

```
curl http://127.0.0.1:31080
Go Web Hello World!
```

Check in the deployment yaml file or the command line into the gitlab repo

#### Answer record

```reStructuredText
### step 1 - pull image 
docker login 
docker pull yichuankaorou/go-web-hello-world:v1.0

### step 2 - vi pod.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: hello
  labels:
    name: hello
spec:
  containers:
  - name: hello
    image: yichuankaorou/go-web-hello-world:v1.0
    imagePullPolicy: IfNotPresent
    ports:
    - containerPort: 8081
      hostPort: 31080
      
### step 3 - config master working as worker and deploy pod.yaml 
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl create -f pod.yaml 

### step 4 - verify 
kubectl get pods 
output>
NAME    READY   STATUS    RESTARTS   AGE
hello   1/1     Running   0          2m55s

curl 148.153.54.132:31080
output>
Go Web Hello World!

### step 5 - push to gitlab 
git add .
git commit -m "add pod.yaml"
git push origin master 
git log 
output>
Author: jizhi.sui <jizhi@163.com>
Date:   Tue Mar 16 13:32:31 2021 +0800

    add pod.yaml
```

------------------------------------

### Task 11: install kubernetes dashboard

and expose the service to nodeport 31081

https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

Expect output: https://127.0.0.1:31081 (asking for token)

#### Answer record

```reStructuredText
### step 1 - wget dashboard yaml 
wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

### step 2 - modify service to expose 31081 port by NodePort  
vi recommended.yaml

kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kubernetes-dashboard
spec:
  type: NodePort
  ports:
    - port: 443
      nodePort: 31081
      targetPort: 8443
  selector:
    k8s-app: kubernetes-dashboard

### step 3 - apply yaml 
kubectl create -f recommended.yaml

### step 4 - verify 
kubectl  get pods -n kubernetes-dashboard
output>
NAME                                         READY   STATUS    RESTARTS   AGE
dashboard-metrics-scraper-7b59f7d4df-8qt29   1/1     Running   0          117s
kubernetes-dashboard-74d688b6bc-gd2fd        1/1     Running   0          117s

netstat -anlp | grep 31081 
output>
tcp        0      0 0.0.0.0:31081           0.0.0.0:*               LISTEN      41877/kube-proxy

### Remind: open the link: https://148.153.54.132:31081 in the chrome to login Dashboard.
```

### Task 12: generate token for dashboard login in task 11

figure out how to generate token to login to the dashboard and publish the procedure to the gitlab.

#### Answer record

```reStructuredText
#### step 1 - generate token 
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
output>
eyJhbGciOiJSUzI1NiIsImtpZCI6IkN3TDhuWVh4SzdFbEhPcVVxYnZMU2ZIeDhtVXVpamZxS09EcVBmVGgtQUkifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJrdWJlcm5ldGVzLWRhc2hib2FyZC10b2tlbi16Z2I4biIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImY2ZTIzZDJkLTIzNzItNDFiOC05YjdmLWU2YmRiOTIwYjAzNiIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlcm5ldGVzLWRhc2hib2FyZDprdWJlcm5ldGVzLWRhc2hib2FyZCJ9.RbQvoG3pRy2bowgTyRdtGrTCy_fa3PIwl4IXoRkCILUdvHSmiwA28R-A_KkslQKllYJ59MnpjeTQcSSPD_ZNqrIaCZ5TyWHoH3ZQv-S7FKsJ5oNS73pVG3WnPWE6xYd3-usOV1JUOGByA2u7gN4pGJjKuzxuE-8zNHksNFTqp6cNQR_ObpZ4HK5lmgAW5Q_M6PMHOzUQXWdMnvzA3vI_CpCuDFd18UM5QAvq4NyAHSfZkDakfEsZGLU6XTIPvaPIjl06MpoKTCJK8O7dVg-deia9Yirzb79hCPwg4dB7IfFB_pOrY4f-AZVdFn27eU7y7j9JOXI5k2h-K6HOjd_btA

### step 2 - login Dashboard 
select Token and paste the token generated 

### step 3 - add all produre in README.md and push to gitlab 
git add .
git commit -m "finish, add all produre in README.md"
git push origin master 
```

--------------------------------------

### Task 13: publish your work

push all files/procedures in your local gitlab repo to remote github repo (e.g. https://github.com/your_github_id/go-web-hello-world)

if this is for an interview session, please send it to yijing.Zheng@ericsson.com, no later than two calendar days after the interview.

#### Answer record 

```reStructuredText
### step 1 - add all produre in README.md and output dashboard to dashboard_token.yaml 
kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}') > dashboard_token.yaml

### step 2 - push to GitHub 
cd /root/go/src/demo/go-web-hello-world 
git init
git add .
git commit -m "task finish"
git push origin master 
git log 
output>
commit 93ac424252d6e161ad022b73e4af6f96fd1ea77c
Author: jizhi.sui <jizhi@163.com>
Date:   Tue Mar 16 16:19:55 2021 +0800

    task finish
```

### Finally Remind

please browse all files in:  https://github.com/yichuankaorou/go-web-hello-world

go-web-hello-world
	├── admin.conf											# k8s admin.conf file 
	├── dashboard_token.yaml					   # dashboard login token 
	├── Dockerfile											  # image dockerfile 
	├── go.mod
	├── pod.yaml												# pod yaml to run container 
	├── README.md										  # store all procedures and answer record 
	├── recommended.yaml
	├── run
	└── run.go

please browse the image in: https://hub.docker.com/repository/docker/yichuankaorou/go-web-hello-world 

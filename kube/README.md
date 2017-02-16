#Kubernetes in the VirtualEnv

It is highly recommended to stand up VS boxes with V_DEV=1, to get more memory and compute allocated to the VM. Performance will drag if not used.


*Note: This is for sake fo example and testing, should only be used for testing, we do not set up external routable IPs for the vs-service. Since no external IP is set up for the vaquero-server(s), the vaquero-agent MUST be deployed in the kubernetes cluster, and use the service `clusterIP` to reach the vaquero-server(s)*


`V_DEV=1 vagrant up` : VS-1 will be the K8s master, VS-1 and all subsequent VS-<num> machines will be K8s minions.

##For all VS machines you stand up (starting kubernetes services)
1. `vagrant ssh vs-<num>`
2. `sudo ./kube-start.sh`

##On any of the VS machines
3. `/vagrant/kube/vs.sh` - sets up a configmap, secret, reploys the `vs-rc` and `vs-svc`
4. `kubectl get svc` - Pull the "clusterIP" off of the `vs-svc`
5. Paste the  "clusterIP" from step 4 into the agent config that lives at `/vagrant/kube/va-config.yaml`
6. `/vagrant/kube/va.sh` - creates a configmap and runs the `va-pod`

##On your physical host
7. `./create_cluster/cluster.sh -d core-cloud` - Booting machines like you would normally.


If configuration changes are required, you must `kubectl delete configmap <configmap-name>` and then `kubectl create configmap <configmap-name> --from-file=<path-to-file>`. See the `va.sh` and `vs.sh` for reference. Renaming the configs will cause the key names to change, and force you to update the `*Pod.yaml` files.


If you wish to use your own container, replace the `image` in the RC or Pod files. Below it add `imagePullPolocy: IfNotPresent` to ensure kubernetes will look at your local docker images before checking the web. *To use local containers the version CANNOT be `latest`, if you use latest it will always pull from the internet*

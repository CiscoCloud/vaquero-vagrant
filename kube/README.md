#Kubernetes in the VirtualEnv

It is highly recommended to stand up VS boxes with V_DEV=1, to get more memory and compute allocated to the VM. Performance will drag if not added.


*Note: This is not a production ready deployment, should only be used for testing, we do not set up external routable IPs for the vs-service, it does not load balance either.*


1. `vagrant ssh vs-1`
2. `sudo ./kube-start.sh`
3. `/vagrant/kube/vs.sh`
4. `kubectl get svc` - Pull the "cluster-IP off of the vs-service"
5. Paste the overlay IP from step 4 into the agent config that lives at `/vagrant/kube/va-config.yaml`
6. `/vagrant/kube/va.sh`
7. Should work to boot single machines.


If configuration changes are required, you must `kubectl delete configmap <configmap-name>` and then `kubectl create configmap <configmap-name> --from-file=<path-to-file>`. See the `va.sh` and `vs.sh` for refernece. Renaming the configs will cause the key names to change, and force you to update the `*Pod.yaml` files.

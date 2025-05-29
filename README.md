# wordpress-k8s-terraform-gitlab
Pet project

## Prerequisites
Kubernetes as platform (docker-desktop, minikube, eks, etc)
Tested on kubernetes, installed by this project: https://github.com/vasichkin/kubernetes-terraform-ansible

## Infrastructure
Kubernetes 

## Task
Deploy application (wordpress) using terraform. Helm used where possible to simplify operations



## Usage
-1. Copy kubernetes access file to kubeconfig/config
0. `terraform init`
1. Fill `terraform.tfvars` with your values
2. Run `terraform plan`
3. Run `terraform apply`
4. Infra should be up and running
To access wordpress, run:
  <cluster_worker_public_ip>:30080
OR 
  `kubectl --kubeconfig kubeconfigs/config -n wordpress port-forward service/wordpress-service 3080:80`
  Go to http://localhost:3080

Perform wordpress installation and setup. Set site url to your domain, pointed to <cluster_worker_ip>. Now your wordpress should be accessible via domain.

## Monitoring
To access grafana endpoint:
1. Run `kubectl --kubeconfig kubeconfigs/config  -n monitoring port-forward service/kube-prometheus-stack-grafana 3000:80`
2. Get grafana password: `kubectl --kubeconfig kubeconfigs/config get secret --namespace monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo` and Go to http://localhost:3000 (creds are: admin/<pass>)
OR
3.  <cluster_public_ip>:30300
4. Import dashboard - 4912 (Kubernetes PHP-FPM)


To access prometheus endpoint:
4. Run `kubectl --kubeconfig kubeconfigs/config -n monitoring port-forward service/kube-prometheus-stack-prometheus 3001:9090` and Go to http://localhost:3001



TODO:
- Add AWS loadbalacer installation
- Service software (nginx, csi-ebs, etc) should bein separate layer/project
- Not all valuable parameters in one place (AWS zone, S3 bucket, etc). Find way to store in centrilized location.
- Auto import grafana dashboards



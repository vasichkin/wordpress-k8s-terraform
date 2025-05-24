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
  `kubectl -n wordpress port-forward service/wordpress-service 8000:80`
  And go to http://localhost:8000/
OR 
  <cluster_public_ip>:30080

Perform wordpress installation and setup. Set site url to your domain, pointed to <cluster_public_ip>. Now your wordpress should be accessible via domain.

## Monitoring
To access grafana endpoint:
1. Run `kubectl -n monitoring port-forward service/kube-prometheus-stack-grafana 3000:80`
2. Get grafana password: `kubectl get secret --namespace monitoring loki-stack-grafana  -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`
3. Go to http://localhost:3000 (creds are: admin/<pass from step 2>)

To access prometheus enfpoint:
1. Run `kubectl -n monitoring port-forward service/kube-prometheus-stack-prometheus 3001:9090`
2. Go to http://localhost:3001 





TODO:
- Add ability to use AWS loadbalacer (not built-in, but manual setup)
- Monitoring: Prometheus. You have to collect metrics from an application like access_log, health status, requests per second. 
- Also metrics from a cluster is needed
- CI/CD. IAC tools and application deployment have to be run from CI/CD of you choice, e.g. Gitlab, Jenkins etc
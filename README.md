# wordpress-k8s-terraform-gitlab
Pet project

## Prerequisites
Kubernetes as platform (docker-desktop, minikube, eks, etc)

## Infrastructure
TODO

## Task
Deploy application (wordpress) using terraform. Helm used where possible to simplify operations



## Usage
1. Fill `terraform.tfvars` with your values
2. Run `terraform plan`
3. Run `terraform apply`
4. Infra should be up and running
To access wordpress, run:
  `kubectl -n wordpress port-forward service/wordpress-service 8000:80`

And go to http://localhost:8000/

## Monitoring
To access grafana endpoint:
1. Run `kubectl -n monitoring port-forward service/kube-prometheus-stack-grafana 3000:3000`
2. Get grafana password: `kubectl get secret --namespace monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`
3. Go to http://localhost:3000 (creds are: admin/<pass from step 2>)

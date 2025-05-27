pipeline {
    agent any

    environment {
        TF_DIR = 'terraform-infra'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/vasichkin/kubernetes-terraform-ansible.git',
                    branch: 'master'
            }
        }

        stage('Prepare tfvars') {
          steps {
            dir('terraform-infra') {
              withCredentials([usernamePassword(credentialsId: 'aws_creds', usernameVariable: 'AWS_ACCESS_KEY', passwordVariable: 'AWS_SECRET_KEY')]) {
                script {
                  // Rewrite this dirty hack
                  def exampleContent = readFile('tfvars.example')
                  def tfvarsContent = exampleContent
                    .replaceAll(/AWS_ACCESS_KEY/, env.AWS_ACCESS_KEY)
                    .replaceAll(/AWS_SECRET_KEY/, env.AWS_SECRET_KEY)
                    .replaceAll(/OWNER/, env.OWNER)
                    .replaceAll("k8s_worker_instance_count = 2", "k8s_worker_instance_count = ${env.k8s_worker_nodes}")
                  writeFile file: 'terraform.tfvars', text: tfvarsContent
                }
              }
            }
          }
        }

        stage('Provision Infrastructure') {
            steps {
                dir("${TF_DIR}") {
                    sh '''
                        echo "Initializing Terraform..."
                        terraform init

                        echo "Applying Terraform..."
                        terraform apply -auto-approve -no-color
                    '''
                }
            }
        }
        stage('Info') {
            steps {
                echo 'User: ubuntu\nSSH key:\n------------------------\n'
                sh 'cat ~/.ssh/id_rsa'
                echo '\n------------------------\n'
                sh './dynamic_inventory.py --show-endpoints'
            }
        }
    }

    post {
        success {
            echo '✅ Infrastructure provisioned successfully!'
        }
        failure {
            echo '❌ Failed to provision infrastructure.'
        }
    }
}

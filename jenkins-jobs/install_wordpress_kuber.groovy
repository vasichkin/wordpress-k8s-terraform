pipeline {
    agent any



    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/vasichkin/kubernetes-terraform-ansible.git',
                    branch: 'master'
            }
        }

        stage('Get kuber creds') {
          steps {

            copyArtifacts fingerprintArtifacts: true,
                projectName: "2-install-kubernetes",
                target: "kubeconfigs/"

          }
        }

        stage('Provision Infrastructure') {
            steps {
                sh '''
                    echo "Initializing Terraform..."
                    terraform init

                    echo "Applying Terraform..."
                    terraform apply -auto-approve -no-color
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Wordpress installed successfully!'
            //sh 'dynamic_inventory.py --describe'
        }
        failure {
            echo '❌ Failed to provision infrastructure.'
        }
    }
}

pipeline {
    agent any



    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/vasichkin/wordpress-k8s-terraform.git',
                    branch: 'master'
            }
        }

        stage('Get kuber creds') {
          steps {
            copyArtifacts fingerprintArtifacts: true,
                projectName: "2-install-kubernetes"
          }
        }

        stage('Prepare tfvars') {
          steps {
            withCredentials([usernamePassword(credentialsId: 'aws_creds', usernameVariable: 'AWS_ACCESS_KEY', passwordVariable: 'AWS_SECRET_KEY')]) {
              script {
                // Rewrite this dirty hack
                def exampleContent = readFile('tfvars.example')
                def tfvarsContent = exampleContent
                  .replaceAll(/OWNER/, env.OWNER)
                writeFile file: 'terraform.tfvars', text: tfvarsContent
              }
            }
          }
        }
        stage('Provision Infrastructure') {
            steps {
                sh '''
                    echo "Initializing Terraform..."
                    terraform init

                    echo "Applying Terraform..."
                    terraform destroy -auto-approve -no-color
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Wordpress destroyed successfully!'
        }
        failure {
            echo '❌ Failed to destroy Wordpress.'
        }
    }
}

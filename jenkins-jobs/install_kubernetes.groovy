pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/vasichkin/kubernetes-terraform-ansible.git',
                    branch: 'master'
            }
        }

        stage('Install kubernetes') {
            steps {
                sh '''
                    echo "Setting up Kubernetes"
                    ansible-playbook -i dynamic_inventory.py main_playbook.yml
                '''
            }
        }
        stage('Save creds') {
            steps {
                archiveArtifacts artifacts: 'kubeconfigs/config', followSymlinks: false
            }
        }
        stage('Info') {
            steps {
                echo 'SSH key:\n------------------------\n'
                sh 'cat ~/.ssh/id_rsa'
                echo '\n------------------------\n'
                sh 'dynamic_inventory.py --show-endpoints'
            }
        }
    }

    post {
        success {
            echo '✅ Kubernetes installed successfully!'
        }
        failure {
            echo '❌ Failed to install kubernetes.'
        }
    }
}

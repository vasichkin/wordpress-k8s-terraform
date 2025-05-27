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
        stage('Creds') {
            archiveArtifacts artifacts: 'kubeconfigs/config', followSymlinks: false
        }
    }

    post {
        success {
            echo '✅ Infrastructure provisioned successfully! SSH key:\n------------------------\n'
            sh 'cat ~/.ssh/id_rsa'
            echo '\n------------------------\nHOSTS provisioned:'
            sh 'dynamic_inventory.py --list'
        }
        failure {
            echo '❌ Failed to provision infrastructure.'
        }
    }
}

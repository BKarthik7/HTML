// Jenkinsfile
pipeline {
    agent any

    environment {
        // Path to your deploy-admin.sh script on the Jenkins controller node
        DEPLOY_ADMIN_SCRIPT = "/home/aagnik/deploy-admin.sh"
        // Path to your new Ansible playbook for deploying the web app
        DEPLOY_WEBAPP_PLAYBOOK = "/home/aagnik/ansible/deploy-webapp.yml"
        // VM name will be dynamic
        VM_APP_NAME = "my-html-app" // Base name for the app
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Checking out code from GitHub...'
                checkout scm
            }
        }

        stage('Provision OpenStack VM') {
            steps {
                script {
                    // Construct a unique VM name for this build
                    env.VM_NAME_FOR_THIS_BUILD = "${VM_APP_NAME}-${BUILD_NUMBER}"
                    echo "Provisioning VM: ${env.VM_NAME_FOR_THIS_BUILD}"
                    // Execute your existing script to create the VM
                    sh "${DEPLOY_ADMIN_SCRIPT} ${env.VM_NAME_FOR_THIS_BUILD}"
                }
            }
        }

        stage('Get VM IP Address') {
            steps {
                script {
                    echo "Attempting to get IP for VM: ${env.VM_NAME_FOR_THIS_BUILD}"

                    def rawAddresses = sh(script: """
                      . /var/snap/microstack/common/etc/microstack.rc
                      openstack server show ${env.VM_NAME_FOR_THIS_BUILD} -f json -c addresses | jq -r '.addresses'
                    """, returnStdout: true).trim()
                    
                    def ips = rawAddresses.replaceFirst('test=', '').split(',').collect { it.trim() }
                    
                    if (ips.size() >= 2) {
                        def secondIp = ips[1].trim().replaceAll('[^0-9\\.]+', '')
                        env.TARGET_VM_IP = secondIp
                        echo "Found second VM IP: ${env.TARGET_VM_IP}"
                    } else {
                        error "Second IP address not found for ${env.VM_NAME_FOR_THIS_BUILD}"
                    }
                }
            }
        }

        stage('Deploy Application Files to VM') {
            when { expression { env.TARGET_VM_IP != null && env.TARGET_VM_IP != "" } }
            steps {
                echo "Deploying application to VM: ${env.TARGET_VM_IP}"
                echo "workspace: ${env.WORKSPACE}"
        
                script {
                    echo "Waiting for SSH to become available on ${env.TARGET_VM_IP}..."
        
                    def maxRetries = 10
                    def delaySeconds = 10
                    def sshReady = false
        
                    for (int i = 1; i <= maxRetries; i++) {
                        def result = sh(
                            script: """
                                ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -o UserKnownHostsFile=/dev/null \
                                    -i /var/lib/jenkins/.ssh/id_rsa ubuntu@${env.TARGET_VM_IP} 'echo SSH is up' || exit 1
                            """,
                            returnStatus: true
                        )
                        if (result == 0) {
                            echo "✅ SSH is ready!"
                            sshReady = true
                            break
                        } else {
                            echo "❌ SSH not ready yet. Attempt $i/$maxRetries. Retrying in ${delaySeconds}s..."
                            sleep(time: delaySeconds, unit: 'SECONDS')
                        }
                    }
        
                    if (!sshReady) {
                        error "❌ SSH never became ready after ${maxRetries} retries"
                    }
                }
        
                ansiblePlaybook(
                    playbook: "${DEPLOY_WEBAPP_PLAYBOOK}",
                    inventory: "${env.TARGET_VM_IP},", // trailing comma for single-host inventory
                    extraVars: [
                        target_vm_ip: env.TARGET_VM_IP,
                        jenkins_workspace: env.WORKSPACE,
                        ansible_user: 'ubuntu',
                        ansible_ssh_private_key_file: "/var/lib/jenkins/.ssh/id_rsa",
                        ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
                    ]
                )
            }
        }
    }
    post {
        always {
            echo 'Pipeline finished.'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}

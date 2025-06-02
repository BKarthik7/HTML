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
                    // This requires OpenStack CLI to be configured for the Jenkins user
                    // and assumes the 'test' network is where the IP will be.
                    // The jq parsing might need adjustment based on your 'openstack server show' output.
                    // Ensure OS_* env vars are available if not using the auth block in the playbook.
                    // Sourcing the RC file here might be needed for the jenkins user

                    ---------------------------
                    def rawIpOutput = sh(script: """
                        . /var/snap/microstack/common/etc/microstack.rc
                        openstack server show ${env.VM_NAME_FOR_THIS_BUILD} -f json -c addresses
                    """, returnStdout: true).trim()
                    
                    echo "Raw IP Output: ${rawIpOutput}"
                    // This parsing is an example and highly dependent on your network setup and OpenStack version
                    // It tries to find the first IPv4 address on the 'test' network.
                    def addressesJson = readJSON text: rawIpOutput
                    def vmIpAddress = ""
                    if (addressesJson.addresses && addressesJson.addresses.test) {
                        for (addrInfo in addressesJson.addresses.test) {
                            if (addrInfo.version == 4) {
                                vmIpAddress = addrInfo.addr
                                break
                            }
                        }
                    }

                    if (vmIpAddress) {
                        env.TARGET_VM_IP = vmIpAddress
                        echo "Found VM IP: ${env.TARGET_VM_IP}"
                    } else {
                        error "Could not determine VM IP address for ${env.VM_NAME_FOR_THIS_BUILD}"
                    }
                }
            }
        }

        stage('Deploy Application Files to VM') {
            // Only run if we got an IP
            when { expression { env.TARGET_VM_IP != null && env.TARGET_VM_IP != "" } }
            steps {
                echo "Deploying application to VM: ${env.TARGET_VM_IP}"
                
                ansiblePlaybook(
                    playbook: "${DEPLOY_WEBAPP_PLAYBOOK}",
                    inventory: "${env.TARGET_VM_IP},", // Note: trailing comma for single-host inventory
                    extraVars: [
                        target_vm_ip: env.TARGET_VM_IP,
                        jenkins_workspace: env.WORKSPACE,
                        ansible_user: 'ubuntu',
                        ansible_ssh_private_key_file: "${System.getProperty('user.home')}/.ssh/id_rsa",
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

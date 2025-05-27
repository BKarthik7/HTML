// Jenkinsfile
pipeline {
    agent any // Runs on any available Jenkins agent/executor

    environment {
        // Define any environment variables needed for your deployment
        VM_NAME_PREFIX = 'my-html-app'
        // Example: DEPLOY_SCRIPT_PATH = "/home/YOUR_USERNAME_ON_CONTROLLER/deploy-admin.sh"
        // Ensure YOUR_USERNAME_ON_CONTROLLER is the user on your Jenkins host (your laptop)
        // that owns and can execute deploy-admin.sh
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Checking out code from GitHub...'
                checkout scm // Checks out the code from the configured SCM (your GitHub repo)
            }
        }

        stage('Build (Placeholder)') {
            // For a simple HTML+CSS+JS app, a "build" might just be linting or archiving.
            // If you had a framework that needed compiling, you'd do it here.
            steps {
                echo 'Building the application (if applicable)...'
                // Example: Archive the workspace for deployment
                // archiveArtifacts artifacts: '**/*', followSymlinks: false
            }
        }

        stage('Deploy to OpenStack VM') {
            steps {
                echo 'Deploying to OpenStack VM...'
                // This assumes your deploy-admin.sh script handles VM creation
                // and you'll later enhance it or add another script/Ansible playbook
                // to copy the HTML/CSS/JS files to the VM.

                // For now, let's just trigger the VM creation.
                // Make sure your Jenkins user has permission to execute this script
                // and that the script can source the OpenStack RC file.
                // You might need to configure sudo access for the jenkins user
                // if microstack.rc or ansible-playbook require it, or ensure
                // the jenkins user has all necessary environment variables.

                // The deploy-admin.sh script expects an APP_NAME
                // We can use the Jenkins build number to make it unique or a fixed name for now
                // sh "/home/YOUR_USERNAME_ON_CONTROLLER/deploy-admin.sh my-html-app-${BUILD_NUMBER}"
                // OR, if deploy-admin.sh is in the workspace (not recommended for shared scripts)
                // sh "./deploy-admin.sh my-html-app-${BUILD_NUMBER}"
            }
        }

        // You would add more stages later, e.g., to copy files to the VM:
        // stage('Transfer Files to VM') {
        //     steps {
        //         echo 'Transferring application files...'
        //         // Use Ansible, scp, or rsync here
        //         // You'd need the IP of the VM created in the previous stage.
        //         // This requires more advanced Jenkinsfile scripting to pass data between stages.
        //     }
        // }
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

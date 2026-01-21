pipeline {
    agent any
    
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_ARGS = '-no-color'
    }
    
    parameters {
        choice(
            name: 'ACTION',
            choices: ['plan', 'apply', 'destroy'],
            description: 'Terraform action to perform'
        )
        booleanParam(
            name: 'AUTO_APPROVE',
            defaultValue: false,
            description: 'Auto-approve terraform apply/destroy (use with caution!)'
        )
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }
        
        stage('Terraform Init') {
            steps {
                echo 'Initializing Terraform...'
                sh '''
                    terraform version
                    terraform init -input=false
                '''
            }
        }
        
        stage('Terraform Validate') {
            steps {
                echo 'Validating Terraform configuration...'
                sh 'terraform validate'
            }
        }
        
        stage('Terraform Plan') {
            steps {
                echo 'Creating Terraform plan...'
                sh 'terraform plan -out=tfplan -input=false'
            }
        }
        
        stage('Manual Approval') {
            when {
                expression { 
                    return params.ACTION != 'plan' && !params.AUTO_APPROVE
                }
            }
            steps {
                script {
                    def userInput = input(
                        id: 'confirm',
                        message: "Do you want to proceed with terraform ${params.ACTION}?",
                        parameters: [
                            [$class: 'BooleanParameterDefinition', 
                             defaultValue: false, 
                             description: 'Confirm action', 
                             name: 'Confirm']
                        ]
                    )
                    if (!userInput) {
                        error("User aborted the pipeline")
                    }
                }
            }
        }
        
        stage('Terraform Apply') {
            when {
                expression { return params.ACTION == 'apply' }
            }
            steps {
                echo 'Applying Terraform changes...'
                sh 'terraform apply -auto-approve tfplan'
            }
        }
        
        stage('Terraform Destroy') {
            when {
                expression { return params.ACTION == 'destroy' }
            }
            steps {
                echo 'Destroying Terraform resources...'
                sh 'terraform destroy -auto-approve'
            }
        }
        
        stage('Show Outputs') {
            when {
                expression { return params.ACTION == 'apply' }
            }
            steps {
                echo 'Terraform Outputs:'
                sh 'terraform output'
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline completed!'
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true)
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}

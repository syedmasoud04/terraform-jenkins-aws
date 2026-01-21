# ============================================================
# JENKINSFILE - CI/CD Pipeline for Terraform
# ============================================================
# This pipeline has 3 simple stages:
#   1. Init     - Setup Terraform
#   2. Plan     - Preview what will be created/changed
#   3. Apply    - Actually create/change resources (needs approval)
# ============================================================

pipeline {
    agent any

    stages {
        // Stage 1: Initialize Terraform
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        // Stage 2: Show what will change
        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        // Stage 3: Wait for approval, then apply
        stage('Terraform Apply') {
            steps {
                // Ask for manual approval before applying
                input message: 'Apply Terraform changes?', ok: 'Apply'
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }

    // After pipeline finishes
    post {
        success { echo '✅ Pipeline completed successfully!' }
        failure { echo '❌ Pipeline failed!' }
    }
}

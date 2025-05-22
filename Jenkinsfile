pipeline {
    agent any
    environment {
        PR_COMMENT = "${env.CHANGE_COMMENT ?: ''}"
    }
    stages {
        stage('Build') {
            steps {
                echo 'Hello Jenkins..'
            }
        }
        stage('Check PR Comment') {
            when {
                expression {
                    return PR_COMMENT.contains('🚀') || PR_COMMENT.contains(':rocket:')
                }
            }
            steps {
                echo "Rocket emoji found, running e2e tests."
            }
        }
        stage('Run Baseline E2E Tests') {
            when {
                expression {
                    return PR_COMMENT.contains('🚀') || PR_COMMENT.contains(':rocket:')
                }
            }
            steps {
                echo 'Running baseline e2e training...'
                // 这里写具体的测试命令
            }
        }
    }
}


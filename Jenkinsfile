pipeline {
    agent any
    parameters {
        string(name: 'ghprbCommentBody', defaultValue: '', description: 'PR 评论内容')
    }
    stages {
        stage('Check PR Comment') {
            when {
                expression {
                    return params.ghprbCommentBody.contains('🚀') || params.ghprbCommentBody.contains(':rocket:')
                }
            }
            steps {
                echo "Triggered by 🚀 PR comment: ${params.ghprbCommentBody}"
            }
        }
        stage('Run Baseline E2E Tests') {
            when {
                expression {
                    return params.ghprbCommentBody.contains('🚀') || params.ghprbCommentBody.contains(':rocket:')
                }
            }
            steps {
                echo 'Running e2e training...'
            }
        }
    }
}

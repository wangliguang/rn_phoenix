pipeline {
    agent any
    environment {
        HOME = '.'
    }
    stages {
        stage('build') {
            steps {
                sh 'npm install'
                sh 'node ./node_modules/react-native/local-cli/cli.js bundle --platform ios --dev false --entry-file index.js --bundle-output ./index.bundle'
                archiveArtifacts artifacts: './index.bundle', fingerprint: true, onlyIfSuccessful: true
            }
        }
    }
}
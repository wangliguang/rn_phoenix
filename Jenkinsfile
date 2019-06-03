pipeline {
    agent any
    environment {
        HOME = '.'
    }
    stages {
        stage('build') {
            steps {
                sh 'rm -r -f node_modules'
                sh 'yarn install'
                sh 'node ./node_modules/react-native/local-cli/cli.js bundle --platform ios --dev false --entry-file index.js --bundle-output ./index.bundle'
                archiveArtifacts archiveArtifacts allowEmptyArchive: true, artifacts: './index.bundle', fingerprint: true, onlyIfSuccessful: true
            }
        }
    }
}
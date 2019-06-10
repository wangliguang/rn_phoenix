pipeline {
    agent any
    environment {
        HOME = '.'
    }
    stages {
        stage('build') {
            steps {
                sh 'yarn install'
                sh 'rm -rf .cache/'
                sh 'whoami'
                sh 'node ./node_modules/react-native/local-cli/cli.js bundle --platform ios --dev false --entry-file index.js --bundle-output ./index.bundle'
                sh 'chmod 744 ./diff.sh && ssh root@47.94.81.19 < ./diff.sh'
            }
        }
    }
}
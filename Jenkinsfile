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
                sh 'scp -r ./index.bundle root@47.94.81.19:/app/s_phoenix/public/bundle'
            }
        }
    }
}
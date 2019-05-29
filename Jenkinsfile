pipeline {
    agent { docker 'node:10.15.2' }
    environment {
        HOME = '.'
    }
    stages {
        stage('build') {
            steps {
                sh 'npm install'
                sh 'node ./node_modules/react-native/local-cli/cli.js bundle --platform ios --dev false --entry-file index.js --bundle-output ./index.bundle'
                sh 'sudo scp ./index.bundle /Users/wangliguang/Desktop/phoenix/s_phoenix/public/bundle'
            }
        }
    }
}
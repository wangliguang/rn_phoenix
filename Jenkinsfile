pipeline {
    agent any
    environment {
        HOME = '.'
    }
    stages {
        stage('build') {
            steps {
                sh 'rm -r -f node_modules'
                sh 'npm install'
                sh 'node ./node_modules/react-native/local-cli/cli.js bundle --platform ios --dev false --entry-file index.js --bundle-output ./index.bundle'
                sh 'scp ./index.bundle /Users/wangliguang/Desktop/phoenix/s_phoenix/public/bundle'
            }
        }
    }
}
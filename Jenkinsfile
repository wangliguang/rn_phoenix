pipeline {
    agent { docker 'node:10.15.2' }
    environment {
        HOME = '.'
    }
    stages {
        stage('build') {
            steps {
                sh 'npm run setup'
                sh 'node ./node_modules/react-native/local-cli/cli.js bundle --platform ios --dev false --entry-file index.js --bundle-output ./ios/platform.ios.bundle'
            }
        }
    }
}
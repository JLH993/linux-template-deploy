#!/usr/bin/env groovy

node {
    stage('checkout') {
        steps {
            checkout scm
        }
    }
    
    stage('shellcheck') {
        steps {
            sh "shellcheck --version"
            sh "shellcheck *.sh"
            }
    }
}
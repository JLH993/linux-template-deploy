#!/usr/bin/env groovy

pipeline {
    agent {
        docker { image 'koalaman/shellcheck:v0.4.6' }
    }
    
    stages {
        
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
}
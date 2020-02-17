#!/usr/bin/env groovy

pipeline {
    agent {
        docker {image 'koalaman/shellcheck:v0.4.6' }
    }
    
    stages {
        
	stage('checkout') {
		checkout scm
	}
	
	stage('shellcheck') {
			sh "shellcheck --version"
			sh "shellcheck *.sh"
	    }
    }
}
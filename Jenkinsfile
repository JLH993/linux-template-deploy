#!/usr/bin/env groovy

node('docker') {
	stage('checkout') {
		checkout scm
	}
	
	stage('shellcheck') {
		docker.image('koalaman/shellcheck:v0.4.6').inside() {
			sh "shellcheck --version"
			sh "shellcheck *.sh"
		}
	}
}
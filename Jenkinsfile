#!/usr/bin/env groovy

node('master') {
	stage('checkout') {
		checkout scm
	}
	
	stage('shellcheck') {
      container('jenkins-dind') {
		docker.image('koalaman/shellcheck:v0.4.6').inside() {
			sh "shellcheck --version"
			sh "shellcheck *.sh"
      }
    }
  }
}
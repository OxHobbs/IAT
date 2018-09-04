stage('Analyze'){
    node('windows') {
        checkout scm
        stash 'everything'
        powershell '.\\build.ps1 -Task \'Analyze\''
    }
}

stage ('Test'){
    node('windows') {
        unstash 'everything'
        powershell '.\\build.ps1 -Task \'Test\''
    }
}

stage ('Publish') {
    node('windows') {
        unstash 'everything'
        nunit testResultsPattern: '*.xml'
    }
}

stage ('Deploy to Dev') {
    node('windows') {
        unstash 'everything'
        powershell '.\\build.ps1 -Task \'DeployToDev\''
    }
}

stage ('Deploy to Prod') {
    input ('Deploy to Production?')
    node('windows') {
        unstash 'everything'
        powershell '.\\build.ps1 -Task \'DeployToProd\''
    }
}    


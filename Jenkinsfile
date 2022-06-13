pipeline {
    
    // Входные параметры для запуска сборки

    parameters {
        string(defaultValue: "${env.jenkinsAgent}", description: 'Нода дженкинса, на которой запускать пайплайн. По умолчанию master', name: 'jenkinsAgent')
        string(defaultValue: "${env.deleteornot}", description: 'Создать новую базу?(по умолчанию - нет)', name: 'deleteornot')
        string(defaultValue: "${env.path1c}", description: 'Путь к запуску 1с в формате "C:/Program Files (x86)/1cv8t/8.3.20.1613/bin/1cv8t.exe"', name: 'path1c')
        string(defaultValue: "${env.local}", description: 'Путь к информационным базам на компьютере', name: 'local')
        string(defaultValue: "${env.platform1c}", description: 'Версия платформы 1с, например 8.3.12.1685. По умолчанию будет использована последня версия среди установленных', name: 'platform1c')
        string(defaultValue: "${env.admin1cUser}", description: 'Имя администратора с правом открытия вншних обработок (!) для базы тестирования 1с ', name: 'admin1cUser')
        string(defaultValue: "${env.admin1cPwd}", description: 'Пароль администратора базы тестирования 1C. ', name: 'admin1cPwd')
        string(defaultValue: "${env.templatebase}", description: 'Название базы данных для создания', name: 'templatebase')
        string(defaultValue: "${env.gitpath}", description: 'Путь к конфигурации базы данных GIT', name: 'gitpath')        

    }
    
    
    
    // нода дженкинса (если не задана в параметрах, то "master")
    
    agent {
        label "${(env.jenkinsAgent == null || env.jenkinsAgent == 'null') ? "master" : env.jenkinsAgent}"   
    }

    // Что может означать, скорее всего время на тест
    options {
        timeout(time: 8, unit: 'HOURS') 
        buildDiscarder(logRotator(numToKeepStr:'10'))
    }


    stages {
        
        // 1 Стадия
        stage('Подготовка') {
            steps {
                timestamps {
                    script {
                    
                    testbase = null

                    dir('build') {
                        writeFile file:'dummy', text:''
                    }

                    }


                }
                
            }
        }
        
    }
}
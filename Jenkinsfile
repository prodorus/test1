@Library("shared-libraries")
import Utils
import ProjectHelpers

def utils = new Utils()
def projectHelpers = new ProjectHelpers()

def createDbTask1
def updateDbTask1 
def runSmoke1cTask1

pipeline {
    
    // Входные параметры для запуска сборки

    parameters {
        booleanParam(defaultValue: "${env.deleteornot}", description: 'Создать новую базу 1C?', name: 'deleteornot')
        string(defaultValue: "${env.jenkinsAgent}", description: 'Нода дженкинса, на которой запускать пайплайн. По умолчанию master', name: 'jenkinsAgent')
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

    options {
        timeout(time: 1, unit: 'HOURS') 
        buildDiscarder(logRotator(numToKeepStr:'10'))
    }

    stages {
        stage("Обновление конфигурации и запуск ИБ 1С") {
            steps {
                timestamps {
                    script {

                            testbase = "${templatebase}"
                            testbaseConnString ="/F${local}\\${testbase}"
                            
                            // 1.  Создание новой 1с базы
                            def createDbTask1 = new createDbTask (
                                testbase,
                                local,
                                deleteornot
                            )

                            // 2. Обновляем тестовую базу из git
                            def updateDbTask1 = new updateDbTask(
                                platform1c,
                                testbase, 
                                testbaseConnString, 
                                admin1cUser, 
                                admin1cPwd,
                                gitpath,
                                path1c
                            )

                             // 3. Запускаем внешнюю обработку 1С, которая очищает базу от всплывающего окна с тем, что база перемещена при старте 1С
                            def runSmoke1cTask1 = new runSmoke1cTask(
                                testbase,
                                admin1cUser,
                                admin1cPwd,
                                testbaseConnString
                            )
                        parallel createDbTask1
                        parallel updateDbTask1
                        parallel runSmoke1cTask1

                    }
                }

            }
        }

        stage("Проведение дымовых тестов") {
            steps {
                timestamps {
                    script {

                        if (templatebase == "") {
                            return
                        }

                        platform1cLine = ""
                        if (platform1c != null && !platform1c.isEmpty()) {
                            platform1cLine = "--v8version ${platform1c}"
                        }

                        admin1cUsrLine = ""
                        if (admin1cUser != null && !admin1cUser.isEmpty()) {
                            admin1cUsrLine = "--db-user ${admin1cUser}"
                        }

                        admin1cPwdLine = ""
                        if (admin1cPwd != null && !admin1cPwd.isEmpty()) {
                            admin1cPwdLine = "--db-pwd ${admin1cPwd}"
                        }
                        // Запускаем ADD тестирование на произвольной базе, сохранившейся в переменной testbaseConnString
                        returnCode = utils.cmd("vrunner xunit --settings tools/vrunner.json ${platform1cLine}  \
                            --ibconnection \"${testbaseConnString}\" ${admin1cUsrLine} ${admin1cPwdLine} ")
                        
                        if (returnCode != 0) {
                            utils.raiseError("Возникла ошибка при запуске ADD на  базе ${testbase}")
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                if (currentBuild.result == "ABORTED") {
                    return
                }

                dir ('build/out/allure') {
                    writeFile file:'environment.properties', text:"Build=${env.BUILD_URL}"
                }

                allure includeProperties: false, jdk: '', results: [[path: 'build/out']]
            }
        }
    }

}

def createDbTask(infobase, local, deleteornot) {
    return {
        stage("Удаление старой и создание новой 1с базы ${infobase}") {
            timestamps {
                def projectHelpers = new ProjectHelpers()
                projectHelpers.creating1cBase(infobase,local,deleteornot)
                
                     

            }
        }
    }

}


def updateDbTask(platform1c, infobase, connString, admin1cUser, admin1cPwd, gitpath, path1c) {
    return {
        stage("Загрузка конфигурации из GIT и ее обновление ${infobase}") {
            timestamps {
                prHelpers = new ProjectHelpers()

                prHelpers.loadCfgFrom1CStorage(infobase, admin1cUser, admin1cPwd, platform1c, gitpath, path1c)
                prHelpers.updateInfobase(connString, admin1cUser, admin1cPwd, platform1c)
                


                
            }
        }
    }
}


def runSmoke1cTask(infobase, admin1cUser, admin1cPwd, testbaseConnString) {
    return {
        stage("Запуск 1с обработки на ${infobase}") {
            timestamps {
                def projectHelpers = new ProjectHelpers()
                projectHelpers.unlocking1cBase(testbaseConnString, admin1cUser, admin1cPwd)
            }

        }
        
    }

}
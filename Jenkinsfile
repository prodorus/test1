@Library("shared-libraries")
import Utils
def utils = new Utils()


def createDbTask1 = [:]
def updateDbTask1 = [:]
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
    


    stages {
        stage("Обновление конфигурации и запуск ИБ 1С") {
            steps {
                timestamps {
                    script {

                            testbase = "${templatebase}"
                            testbaseConnString ="/F${local}\\${testbase}"
                            
                            // 1.  Создание новой 1с базы
                            createDbTask1["createTask_${testbase}"] = createDbTask (
                                testbase,
                                local,
                                deleteornot
                            )

                            // 2. Обновляем тестовую базу из git
                            updateDbTask1["updateTask_${testbase}"] = updateDbTask(
                                platform1c,
                                testbase, 
                                testbaseConnString, 
                                admin1cUser, 
                                admin1cPwd,
                                gitpath,
                                path1c
                            )

                            

                        parallel createDbTask1
                        parallel updateDbTask1
                       
                    }
                }



        
            }
        }
    }

}



def createDbTask(infobase, local, deleteornot) {
    return {
        stage("Удаление старой и создание новой 1с базы ${infobase}") {
            timestamps {
                if (deleteornot != null && !deleteornot.isEmpty() && deleteornot =="нет"){

    
                }   
    
                else if (deleteornot == "да") {
                    utils = new Utils()

                    utils.powershell("Remove-Item -Recurse -Force -Path \"${local}/${infobase}\" ")

                    utils.cmd("\"${path1c}\" CREATEINFOBASE FILE=\"${local}/${infobase}\" ")
                   
                }
                     

            }
        }
    }

}


def updateDbTask(platform1c, infobase, connString, admin1cUser, admin1cPwd, gitpath, path1c) {
    return {
        stage("Загрузка конфигурации из GIT и ее обновление ${infobase}") {
            timestamps {
                utils = new Utils()

                returnCode = utils.cmd("rd /s/q \"${env.WORKSPACE}/confs/${infobase}")


                returnCode = utils.cmd("git clone ${gitpath} \"${env.WORKSPACE}/confs/${infobase}")
                if (returnCode != 0) {
                    utils.raiseError("Загрузка конфигурации из github  ${infobase} завершилась с ошибкой. ")
                }

                 if (admin1cPwd != null && !admin1cPwd.isEmpty()) {
                    returnCode = utils.cmd("\"${path1c}\" DESIGNER /F${local}/${infobase}  /LoadConfigFromFiles ${env.WORKSPACE}\\confs\\${infobase} /N ${admin1cUser} /P ${admin1cPwd} ")
                    if (returnCode != 0) {
                        utils.raiseError("Загрузка конфигурации из папки \"${env.WORKSPACE}/confs завершилась с ошибкой.")}
                
                } else {
                    returnCode = utils.cmd("\"${path1c}\" DESIGNER /F${local}/${infobase}  /LoadConfigFromFiles ${env.WORKSPACE}\\confs\\${infobase} /N ${admin1cUser}")
                    if (returnCode != 0) {
                    utils.raiseError("Загрузка конфигурации из папки \"${env.WORKSPACE}/confs завершилась с ошибкой.")
                }

                }

                
            }
        }
    }
}

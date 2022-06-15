#Использовать v8runner
#Использовать cmdline

Перем СЕРВЕР;
Перем СЕРВЕР_ПОРТ;
Перем БАЗА;
Перем ЭТО_ФАЙЛОВАЯ_БАЗА;
Перем ПОЛЬЗОВАТЕЛЬ;
Перем ПАРОЛЬ;
Перем ПЛАТФОРМА_ВЕРСИЯ;
Перем РАБОЧИЙ_КАТАЛОГ;
Перем ПУТЬ_К_ПОСТАВКЕ;
Перем Конфигуратор;
Перем Лог;

Функция Инициализация()

    Парсер = Новый ПарсерАргументовКоманднойСтроки();
    Парсер.ДобавитьИменованныйПараметр("-platform");
    Парсер.ДобавитьИменованныйПараметр("-server");
    Парсер.ДобавитьИменованныйПараметр("-base");
    Парсер.ДобавитьИменованныйПараметр("-user");
    Парсер.ДобавитьИменованныйПараметр("-passw");
    Парсер.ДобавитьИменованныйПараметр("-distribfolder");

    Параметры = Парсер.Разобрать(АргументыКоманднойСтроки);
    
    ПЛАТФОРМА_ВЕРСИЯ  = Параметры["-platform"];//"8.3.10.2639"; // если пустая строка, то будет взята последняя версия
    СЕРВЕР            =  Параметры["-server"];
    СЕРВЕР_ПОРТ       = 1541; // 1541 - по умолчанию
    БАЗА              =  Параметры["-base"];
    ЭТО_ФАЙЛОВАЯ_БАЗА = Не ЗначениеЗаполнено(СЕРВЕР);
    ПОЛЬЗОВАТЕЛЬ      = Параметры["-user"];
    ПАРОЛЬ            = Параметры["-passw"];

    ПУТЬ_К_ПОСТАВКЕ   = Параметры["-distribfolder"];

    Конфигуратор = Новый УправлениеКонфигуратором();
    Конфигуратор.УстановитьКонтекст(СтрокаСоединенияИБ(), ПОЛЬЗОВАТЕЛЬ, ПАРОЛЬ);
    Конфигуратор.ИспользоватьВерсиюПлатформы(ПЛАТФОРМА_ВЕРСИЯ);

    Лог = Логирование.ПолучитьЛог("createDistribPackage");

КонецФункции

Функция СоздатьФайлПоставки()

    Конфигуратор.СоздатьФайлыПоставки(ПУТЬ_К_ПОСТАВКЕ + "/1cv8.cf", ПУТЬ_К_ПОСТАВКЕ +"/1cv8.cfu");

КонецФункции

Функция СтрокаСоединенияИБ() 
    Если ЭТО_ФАЙЛОВАЯ_БАЗА Тогда
        Возврат "/F" + БАЗА; 
    Иначе   
        Возврат "/IBConnectionString""Srvr=" + СЕРВЕР + ?(ЗначениеЗаполнено(СЕРВЕР_ПОРТ),":" + СЕРВЕР_ПОРТ,"") + ";Ref='"+ БАЗА + "'""";
    КонецЕсли;
КонецФункции

Инициализация();
Лог.Информация("Creating distribution package...");
СоздатьФайлПоставки();
Лог.Информация("Sucessfuly created ditribution support");
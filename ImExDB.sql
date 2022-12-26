$rman --запуск утилиты
Connect Target System/Ne1slomaesh@//Localhost:1521/Kurs; --строка подключения
select file_name from dba_data_files; --файлы для копирования


backup database; --создать копию

EXIT --отключиться от утилиты


list backup; --лист копий

restore database; --восстановить бд

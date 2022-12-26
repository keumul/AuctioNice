----------------------------------- [XML] -----------------------------------
CREATE OR REPLACE DIRECTORY EXPORT_FILE
    AS 'C:\XML_courseproject';


-----------------------------------------------------------------------------
--export
 create or replace procedure users_export is
 file1 utl_file.file_type;
 xrow CLOB ;
 Begin
 file1 := UTL_FILE.FOPEN('EXPORT_FILE', 'users.xml', 'w');

 SELECT XMLELEMENT(root,XMLAGG(XMLELEMENT(appuser,
        XMLATTRIBUTES(
          e.id,
          e.email,
          e.password,
          e.account)
        ))).getCLOBVal() AS xmlsads
    INTO Xrow
        FROM Users e;
 utl_file.put(file1, xrow);
 utl_file.fclose(file1);
 end;

 --import
 create or replace procedure users_import
 is
 file1 utl_file.file_type;
 xrow CLOB;
 begin
 file1 := UTL_FILE.FOPEN('EXPORT_FILE', 'users_import.xml', 'r');
 utl_file.get_line(file1, xrow);

 MERGE INTO Users cur_t USING
    (SELECT extractvalue(value(T),'//@ID'      ) id,
            extractvalue(value(T),'//@EMAIL'   ) email,
            extractvalue(value(T),'//@PASSWORD') password,
            extractvalue(value(T),'//@USERNAME') username,
            extractvalue(value(T),'//@ACCOUNT' ) account
    FROM TABLE(XMLSequence(XMLType(xrow).extract('//APPUSER'))) T)
        imp_t ON (cur_t.id=imp_t.id)
WHEN NOT MATCHED THEN
    INSERT(
      cur_t.id,
      cur_t.email,
      cur_t.password,
      cur_t.username,
      cur_t.account)
    VALUES(
      imp_t.id,
      imp_t.email,
      imp_t.password,
      imp_t.username,
      imp_t.account);
  Utl_File.fclose(File1);
 end;

-------------------------------------------------------------------------------
BEGIN
    users_export;
    --users_import;
END;

SELECT * FROM users;
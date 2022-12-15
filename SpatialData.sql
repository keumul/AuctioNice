----------------------------------- [XML] -----------------------------------
CREATE OR REPLACE DIRECTORY EXPORTFILE
    AS 'C:\\Users\\sssap\\Desktop\\COURSE PROJECT\\XmlFiles';

-----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE export_users
IS
    file1 utl_file.file_type;
    xrow CLOB;
BEGIN
    file1 := UTL_FILE.FOPEN('EXPORTFILE','users.txt','w');
    SELECT XMLELEMENT(root,XMLAGG(XMLELEMENT(appuser,
        XMLATTRIBUTES(
          e.id,
          e.email,
          e.password,
          e.account)
        ))).getCLOBVal() AS xmlsads
    INTO Xrow
        FROM Users e;
  utl_file.put(file1,xrow);
  utl_file.fclose(file1);
END;

-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE import_users
IS
    file1 utl_file.file_type;
    xrow CLOB;
BEGIN
    file1 := UTL_FILE.FOPEN('EXPORTFILE','users.txt','r');
    utl_file.get_line(file1,xrow);
    MERGE INTO Users cur_t USING
    (SELECT extractvalue(value(T),'//@ID'      ) id,
            extractvalue(value(T),'//@EMAIL'   ) email,
            extractvalue(value(T),'//@PASSWORD') password,
            extractvalue(value(T),'//@ACCOUNT' ) account
    FROM TABLE(XMLSequence(XMLType(xrow).extract('//APPUSER'))) T)
        imp_t ON (cur_t.id=imp_t.id)
WHEN NOT MATCHED THEN
    INSERT(
      cur_t.id,
      cur_t.email,
      cur_t.password,
      cur_t.account)
    VALUES(
      imp_t.id,
      imp_t.email,
      imp_t.password,
      imp_t.account);
  Utl_File.fclose(File1);
end;

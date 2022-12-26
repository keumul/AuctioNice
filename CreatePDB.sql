ALTER SESSION SET NLS_LANGUAGE= 'american';
alter
session set "_ORACLE_SCRIPT"= true;

create
pluggable database auctionice_pdb
    admin user developer identified by dev123
    storage (maxsize 4 G)
    default tablespace project_TS
        datafile 'auctionice.dbf'
        size 100 m autoextend on
    file_name_convert = ('pdbseed','auctionice_pdb');

-- GOTO pdb.sys
GRANT CREATE SESSION TO developer WITH ADMIN OPTION;
GRANT CREATE TABLESPACE TO developer WITH ADMIN OPTION;
GRANT CREATE PROFILE TO developer WITH ADMIN OPTION;
GRANT CREATE ROLE TO developer WITH ADMIN OPTION;
GRANT CREATE USER TO developer WITH ADMIN OPTION;
GRANT CREATE TABLE TO developer WITH ADMIN OPTION;
GRANT CREATE VIEW TO developer WITH ADMIN OPTION;
GRANT CREATE PROCEDURE TO developer WITH ADMIN OPTION;
GRANT UPDATE ANY TABLE TO developer WITH ADMIN OPTION;
GRANT CREATE SEQUENCE TO developer WITH ADMIN OPTION;
GRANT SELECT ANY SEQUENCE TO developer WITH ADMIN OPTION;
GRANT CREATE TRIGGER TO developer WITH ADMIN OPTION;
GRANT CREATE SYNONYM TO developer WITH ADMIN OPTION;
GRANT CREATE ANY DIRECTORY TO developer WITH ADMIN OPTION;
GRANT CREATE ANY CONTEXT TO developer WITH ADMIN OPTION;
grant SELECT_CATALOG_ROLE to DEVELOPER;
grant SELECT ANY DICTIONARY to DEVELOPER;

CREATE OR REPLACE DIRECTORY EXPORT_FILE
    AS 'C:\XML_courseproject';

GRANT READ, WRITE ON DIRECTORY EXPORT_FILE TO developer;



GRANT DROP ANY TABLE,
      DROP ANY VIEW,
      DROP TABLESPACE,
      DROP ANY PROCEDURE,
      DROP USER TO developer;
alter user developer quota unlimited on PROJECT_TS;
--

select name, open_mode
from v$pdbs;
select PDB_NAME,STATUS from cdb_pdbs;
alter
pluggable database auctionice_pdb open;

alter
pluggable database auctionice_pdb save state;

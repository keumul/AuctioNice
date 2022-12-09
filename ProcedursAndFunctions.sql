------------------------ [PASSWORD ENCRYPTION] -------------------------------------
--DROP FUNCTION encrypt_password;
CREATE OR REPLACE FUNCTION encrypt_password
    (user_password_param IN users.password%TYPE)
    RETURN users.password%TYPE
IS
    l_key VARCHAR2(2000) := '3867204957482756';
    l_in_val VARCHAR2(2000) := user_password_param;
    l_mod NUMBER := DBMS_CRYPTO.encrypt_aes128 + DBMS_CRYPTO.chain_cbc + DBMS_CRYPTO.pad_pkcs5;
    l_enc RAW(2000);
BEGIN
      l_enc := DBMS_CRYPTO.encrypt(utl_i18n.string_to_raw(l_in_val, 'AL32UTF8'),
                                   l_mod,
                                   utl_i18n.string_to_raw(l_key, 'AL32UTF8'));
    RETURN RAWTOHEX(l_enc);
END encrypt_password;

------------------------ [PASSWORD DESCRIPTION] ------------------------------------
--DROP FUNCTION decrypt_password;
CREATE OR REPLACE FUNCTION decrypt_password
    (user_password_param IN users.password%TYPE)
    RETURN users.password%TYPE
IS
    l_key VARCHAR2(2000) := '3867204957482756';
    l_in_val RAW(2000) := HEXTORAW(user_password_param);
    l_mod NUMBER := DBMS_CRYPTO.encrypt_aes128 + DBMS_CRYPTO.chain_cbc + DBMS_CRYPTO.pad_pkcs5;
    l_dec RAW(2000);
BEGIN
    l_dec := DBMS_CRYPTO.decrypt(l_in_val,
                                 l_mod,
                                 utl_i18n.string_to_raw(l_key, 'AL32UTF8'));
    RETURN utl_i18n.raw_to_char(l_dec);
END decrypt_password;

------------------------ [SIGN UP] -------------------------------------------------
--DROP PROCEDURE signup_procedure;
CREATE OR REPLACE PROCEDURE signup_procedure(
    new_login IN varchar2,
    new_password IN varchar2,
    username IN varchar2
    )
IS
    coincidences NUMBER;
    new_person_id NUMBER;
    NULL_PARAMETER EXCEPTION;
BEGIN
    IF(new_login IS NULL OR new_password IS NULL)
    THEN RAISE NULL_PARAMETER;
    END IF;

    SELECT COUNT(*) INTO coincidences
    FROM users
    WHERE UPPER(users.EMAIL) = UPPER(new_login);

    IF(coincidences = 0) THEN
        INSERT INTO users(EMAIL, PASSWORD, USERNAME)
        values (new_login, new_password, username)
        RETURNING
            users.id INTO new_person_id;
        commit;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Current username is already exists!');
    END IF;
EXCEPTION
    WHEN NULL_PARAMETER
        THEN RAISE_APPLICATION_ERROR(-20005, 'Some parameters cannot be null!');
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR(-20006, sqlerrm);
END signup_procedure;

------------------------ [SET ROLE] ------------------------------------------------
--DROP PROCEDURE set_role_to_user;
CREATE OR REPLACE PROCEDURE set_role_to_user
    (
    username IN nvarchar2,
    chosen_role_id IN nvarchar2
    )
IS
    coincidences NUMBER;
    found_role NUMBER;
    NULL_PARAMETER EXCEPTION;
    INCORRECT_NUMBER EXCEPTION;
BEGIN
    IF(chosen_role_id <= 0)
    THEN RAISE INCORRECT_NUMBER;
    END IF;

   SELECT COUNT(*) INTO found_role
    FROM roles
    WHERE roles.role_id = chosen_role_id;

    IF(found_role !=1)
    THEN RAISE NO_DATA_FOUND;
    END IF;

    SELECT COUNT(*) INTO coincidences
    FROM users
    WHERE UPPER(users.EMAIL) = UPPER(username);

    IF(coincidences = 1)
        THEN
        UPDATE users
        SET role_id = chosen_role_id
        WHERE users.EMAIL = username;
    ELSE
        RAISE_APPLICATION_ERROR(-20002, 'User does not exists!');
    END IF;
EXCEPTION
    WHEN INCORRECT_NUMBER
        THEN RAISE_APPLICATION_ERROR(-20007, 'Write a correct number!');
    WHEN NULL_PARAMETER
        THEN RAISE_APPLICATION_ERROR(-20005, 'Some parameters cannot be null!');
    WHEN NO_DATA_FOUND
        THEN RAISE_APPLICATION_ERROR(-20008, 'Cannot find role!');
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR(-20006, sqlerrm);
END set_role_to_user;

BEGIN
    set_role_to_user('meow', 2);
END;

SELECT * FROM users;

------------------------ [SIGN IN] -------------------------------------------------
--DROP PROCEDURE signin_procedure
CREATE OR REPLACE PROCEDURE signin_procedure
    (
    p_username IN OUT users.email%TYPE,
    p_password IN users.password%TYPE,
    p_role_id OUT users.role_id%TYPE
    )
IS
    NULL_PARAMETER EXCEPTION;
    user_found NUMBER;
BEGIN

    IF(p_username IS NULL OR p_password IS NULL)
    THEN RAISE NULL_PARAMETER;
    END IF;

    SELECT COUNT(*)
    INTO user_found
    FROM users
    WHERE email = p_username;

    IF(user_found != 1)
        THEN RAISE NO_DATA_FOUND;
    END IF;

    SELECT email, role_id
    INTO p_username, p_role_id
    FROM users
    WHERE email= p_username
        AND encrypt_password(UPPER(p_password)) = password;

EXCEPTION
    WHEN NULL_PARAMETER
        THEN RAISE_APPLICATION_ERROR(-20005, 'Some parameters cannot be null!');
    WHEN NO_DATA_FOUND
        THEN RAISE_APPLICATION_ERROR(-20003, 'Cannot find user!');
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR(-20007, sqlerrm);
END signin_procedure;

------------------------ [ADD MONEY] ------------------------------------
CREATE OR REPLACE PROCEDURE add_money_procedure
    (
    p_id    INT,
    p_value INT
    )
IS
    NULL_PARAMETER EXCEPTION;
    user_found NUMBER;
begin
    UPDATE Users
    SET account = account + p_value
    WHERE id = p_id;

    IF(p_id IS NULL OR p_value IS NULL)
    THEN RAISE NULL_PARAMETER;
    END IF;

    IF(user_found != 1)
        THEN RAISE NO_DATA_FOUND;
    END IF;

EXCEPTION
    WHEN NULL_PARAMETER
        THEN RAISE_APPLICATION_ERROR(-20005, 'Some parameters cannot be null!');
    WHEN NO_DATA_FOUND
        THEN RAISE_APPLICATION_ERROR(-20003, 'Cannot find user!');
    WHEN OTHERS
        THEN RAISE_APPLICATION_ERROR(-20007, sqlerrm);
end;
/

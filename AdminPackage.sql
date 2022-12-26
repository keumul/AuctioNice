--DROP PACKAGE admin_package;

CREATE OR REPLACE PACKAGE admin_package AS
    PROCEDURE delete_item_procedure(id_p number);
    PROCEDURE delete_items_category(itemid_p number);
    FUNCTION get_current_auction_function(date_p DATE) RETURN SYS_REFCURSOR;
    FUNCTION get_item_function(item IN NUMBER) RETURN SYS_REFCURSOR;
    FUNCTION get_item_category_function(type_ INT) RETURN SYS_REFCURSOR;
    PROCEDURE delete_auction_procedure(id_p number);
    PROCEDURE delete_auction_items(auctionid_p number);
    PROCEDURE add_category_procedure(
        name_p VARCHAR2);
    PROCEDURE signup_procedure(
        email_p IN VARCHAR2,
        password_p IN VARCHAR2,
        username_P IN VARCHAR2);
    PROCEDURE signin_procedure(
        p_login IN OUT VARCHAR2,
        p_password IN VARCHAR2
        );
    PROCEDURE add_auction(
        categoryid_p INT,
        startdate_p DATE);
    FUNCTION get_all_users_pagination(
        page_number_in NUMBER,
        page_size_in NUMBER) RETURN SYS_REFCURSOR;
END admin_package;


CREATE OR REPLACE PACKAGE BODY admin_package AS
    ------------------------ [SIGN UP] -------------------------------------------------
--DROP PROCEDURE signup_procedure;
    PROCEDURE signup_procedure(
        email_p IN VARCHAR2,
        password_p IN VARCHAR2,
        username_P IN VARCHAR2) IS
    BEGIN
        INSERT INTO users (email, password, username, role_id)
        VALUES (email_p, ORA_HASH(password_p), username_p, 1);
        COMMIT;
    END signup_procedure;

------------------------ [SIGN IN] -------------------------------------------------
--DROP PROCEDURE signin_procedure;
    PROCEDURE signin_procedure(
        p_login IN OUT VARCHAR2,
        p_password IN VARCHAR2)
        IS
        notification_ sys_refcursor;
        NULL_PARAMETER EXCEPTION;
        user_found NUMBER;
    BEGIN
        IF (p_password IS NULL)
        THEN
            RAISE NULL_PARAMETER;
        END IF;

        SELECT COUNT(*)
        INTO user_found
        FROM users
        WHERE email = p_login;
        COMMIT ;
        IF (user_found != 1)
        THEN
            RAISE NO_DATA_FOUND;
        END IF;

        SELECT email
        INTO p_login
        FROM users
        WHERE email = p_login
        AND ORA_HASH(p_password) = password;
        COMMIT ;
    EXCEPTION
        WHEN NULL_PARAMETER
            THEN RAISE_APPLICATION_ERROR(-20005, 'Some parameters cannot be null!');
        WHEN NO_DATA_FOUND
            THEN RAISE_APPLICATION_ERROR(-20003, 'Cannot find user!');
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR(-20007, SQLERRM);
    END signin_procedure;
--

-- ------------------------ [DELETE ITEM] ------------------------------------
--DROP PROCEDURE delete_item_procedure
    PROCEDURE delete_item_procedure(
        id_p number)
        IS
    BEGIN
        if (id_p IS NULL)
        THEN
            RAISE_APPLICATION_ERROR(-20005, 'Some parameters cannot be null!');
        END IF;

        delete_items_category(id_p);
        DELETE
        FROM Item
        WHERE id = id_p;
        COMMIT ;
    EXCEPTION
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR
                (-20010, 'Something went wrong with delete_item_procedure');
    END delete_item_procedure;
--
-- ------------------------ [DELETE ITEMS CATEGORY] ------------------------------------
--DROP PROCEDURE delete_items_category;
    PROCEDURE delete_items_category(
        itemid_p number)
        IS
    BEGIN
        DELETE
        FROM ItemsCategory
        WHERE itemid = itemid_p;
        COMMIT ;
    EXCEPTION
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR
                (-20011, 'Something went wrong with delete_items_category');
    END delete_items_category;

-- ------------------------ [GET CURRENT AUCTION] ------------------------------------
--DROP FUNCTION get_current_auction_function
    FUNCTION get_current_auction_function(
        date_p DATE)
        RETURN sys_refcursor IS
        get_current_auction sys_refcursor;
    BEGIN
        OPEN get_current_auction FOR
            SELECT *
            FROM Auction
            WHERE startdate = date_p;
        RETURN get_current_auction;
    EXCEPTION
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR
                (-20010, 'Something went wrong with get_current_auction_function');
    END get_current_auction_function;

-- ------------------------ [GET ITEM] ------------------------------------
--DROP FUNCTION get_item_function;
    FUNCTION get_item_function(item IN NUMBER)
        RETURN sys_refcursor AS
        item_cursor sys_refcursor;
    BEGIN
        OPEN item_cursor FOR
            SELECT id,
                   title,
                   description,
                   endtime,
                   startprice,
                   winnerprice
            FROM Item
            WHERE id = item;
        RETURN (item_cursor);
    EXCEPTION
        WHEN OTHERS THEN RAISE_APPLICATION_ERROR
            (-20010, 'Something went wrong with get_item_procedure');
    END get_item_function;

------------------------ [GET ITEM CATEGORY] ------------------------------------
--DROP FUNCTION get_item_category_function
    FUNCTION get_item_category_function(
        type_ INT)
        RETURN sys_refcursor AS
        item_category sys_refcursor;
    BEGIN
        OPEN item_category
            FOR SELECT id,
                       title,
                       description,
                       endtime,
                       startprice,
                       winnerprice,
                       category_title
                FROM ITEM_CATEGORY_VIEW
                WHERE id = type_;
        RETURN (item_category);
    EXCEPTION
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR
                (-20010, 'Something went wrong with get_item_category_function');
    END get_item_category_function;

-- ------------------------ [ADD CATEGORY] ------------------------------------
-- --DROP PROCEDURE add_category_procedure;
    PROCEDURE add_category_procedure(
        name_p VARCHAR2)
        IS
        count_p int;
        CATEGORY_EXISTS EXCEPTION;
    BEGIN
        SELECT COUNT(*)
        INTO count_p
        FROM Category
        WHERE title = name_p;
        COMMIT ;
        IF count_p = 0 THEN
            INSERT INTO Category(title)
            VALUES (name_p);
        ELSIF count_p > 0 THEN
            RAISE CATEGORY_EXISTS;
        END IF;
    EXCEPTION
        WHEN CATEGORY_EXISTS
            THEN RAISE_APPLICATION_ERROR
                (-20010, 'Category already exists!');
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR
                (-20010, 'Something went wrong with add_category_procedure');
    END add_category_procedure;

-- ------------------------ [ADD AUCTION] ------------------------------------
--DROP PROCEDURE add_auction_procedure;
    PROCEDURE add_auction(
        categoryid_p INT,
        startdate_p DATE)
        IS
        count_p int;
        AUCTION_EXISTS EXCEPTION;
        CANNOT_BE_IN_PAST EXCEPTION;
    BEGIN
        SELECT COUNT(*)
        INTO count_p
        FROM Auction
        WHERE categoryid = categoryid_p
          AND startdate = startdate_p;
        COMMIT ;
        IF (startdate_p < SYSDATE) THEN
            RAISE CANNOT_BE_IN_PAST;
        END IF;
        IF (count_p > 0) THEN
            RAISE AUCTION_EXISTS;
        END IF;
        IF count_p = 0 AND startdate_p > SYSDATE
        THEN
            INSERT INTO AUCTION
                (categoryid, startDate)
            VALUES (categoryid_p, startdate_p);
            COMMIT ;
        END IF;
    EXCEPTION
        WHEN AUCTION_EXISTS
            THEN RAISE_APPLICATION_ERROR
                (-20010, 'Auction already exists');
        WHEN CANNOT_BE_IN_PAST
            THEN RAISE_APPLICATION_ERROR
                (-20010, 'Auction cannot be in the past');
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR
                (-20010, 'Something went wrong with add_auction');
    END add_auction;

-- ------------------------ [DELETE AUCTION] ------------------------------------
--DROP PROCEDURE delete_auction_procedure;
    PROCEDURE delete_auction_procedure(
        id_p number)
        IS
    BEGIN
        delete_auction_items(id_p);
        COMMIT ;
        DELETE
        FROM Auction
        WHERE id = id_p;
        COMMIT ;
    EXCEPTION
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR
                (-20010, 'Something went wrong with delete_auction');
    END delete_auction_procedure;

-- ------------------------ [DELETE AUCTION ITEMS] ------------------------------------
--DROP PROCEDURE delete_auction_items;
    PROCEDURE delete_auction_items(
        auctionid_p number)
        IS
    BEGIN
        DELETE
        FROM ItemsAuction
        WHERE auctionid = auctionid_p;
        COMMIT ;
    EXCEPTION
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR
                (-20010, 'Something went wrong with delete_auction_items');
    END delete_auction_items;
--
-- ------------------------ [GET USERS PAGINATION] ------------------------------------
    FUNCTION get_all_users_pagination(
        page_number_in NUMBER,
        page_size_in NUMBER)
        RETURN sys_refcursor IS
        users_cursor sys_refcursor;
    BEGIN
        OPEN users_cursor FOR
            SELECT id, email, username, account
            FROM (SELECT ROWNUM AS row_num, users.*
                  FROM users
                  WHERE ROWNUM <= page_number_in * page_size_in)
            WHERE row_num > (page_number_in - 1) * page_size_in;
        RETURN users_cursor;
    EXCEPTION
        WHEN OTHERS THEN RAISE_APPLICATION_ERROR
            (-20010, 'Something went wrong with get_all_users_pagination');
    END get_all_users_pagination;

END admin_package;




--     PROCEDURE delete_item_procedure(id_p INT);           +
--     PROCEDURE delete_items_category(itemid_p INT);       +
--     FUNCTION get_current_auction_function(date_p DATE)   +
--     FUNCTION get_item_function(item IN ITEM.ID%type)     +
--     FUNCTION get_item_category_function(type_ INT)       +
--     PROCEDURE delete_auction_procedure(id_p INT);        +
--     PROCEDURE delete_auction_items(auctionid_p INT);     +
--     PROCEDURE add_category_procedure                     +
--     PROCEDURE signup_procedure                           +
--     PROCEDURE signin_procedure                           +
--     PROCEDURE add_auction                                +
--     FUNCTION get_all_users_pagination                    +
----------------------------------- [TEST] -----------------------------------
-- admin signup
BEGIN
    admin_package.signup_procedure('testadmin@gmail.com', 'root', 'Test');
END;

select * from users;
-- admin login
DECLARE
    login_ VARCHAR2(255) := 'testadmin@gmail.com';
BEGIN
    admin_package.signin_procedure(login_, 'root');
END;

-- admin add auction
DECLARE
    auction_type_ NUMBER := 1;
    start_date_   DATE  := TO_DATE('31/12/2022', 'DD/MM/YYYY');
BEGIN
    admin_package.add_auction(auction_type_, start_date_);
END;


-- admin add category
DECLARE
    category_ VARCHAR2(255) := 'category1';
BEGIN
    admin_package.add_category_procedure(category_);
END;

--admin get users pagination

DECLARE
    users_cursor sys_refcursor;
    id_p         NUMBER;
    email_p      VARCHAR2(255);
    name_p       VARCHAR2(255);
    account_p    NUMBER;
    page_p       number := 1;
    count_p      number := 5;
BEGIN
    users_cursor := admin_package.get_all_users_pagination(page_p, count_p);
    DBMS_OUTPUT.PUT_LINE( lpad('id', 5) || lpad('email', 25) || lpad('name', 20) || lpad('account', 10));
    LOOP
        FETCH users_cursor INTO id_p, email_p, name_p, account_p;
        EXIT WHEN users_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE( lpad(id_p, 5) || lpad(email_p, 25) || lpad(name_p, 20) || lpad(account_p, 10));
    END LOOP;
END;

-- admin delete item
DECLARE
    id_p INT := 21;
BEGIN
    admin_package.delete_item_procedure(id_p);
END;


-- admin delete items category
DECLARE
    id_p INT := 21;
BEGIN
    admin_package.delete_items_category(id_p);
END;

SELECT *
FROM ITEMSCATEGORY;

-- admin delete auction
DECLARE
    id_p INT := 1;
BEGIN
    admin_package.delete_auction_procedure(id_p);
END;

SELECT *
FROM AUCTION;

-- admin delete items auction
DECLARE
    id_p INT := 1;
BEGIN
    admin_package.delete_auction_items(id_p);
END;

--get_item_function
DECLARE
    item_cursor   sys_refcursor;
    id_p          NUMBER;
    title_p        VARCHAR2(255);
    description_p VARCHAR2(255);
    endtime_p     DATE;
    startprice_p  NUMBER;
    winnerprice_p NUMBER;

BEGIN
    item_cursor := admin_package.get_item_function(23);
    DBMS_OUTPUT.PUT_LINE('[Items list]');
    DBMS_OUTPUT.PUT_LINE(lpad('id', 5) || lpad('title', 10) || lpad('description', 20) || lpad('end time', 20) || lpad('start price', 20) || lpad('winner price', 20));
    LOOP
        FETCH item_cursor
        INTO id_p, title_p, description_p, endtime_p, startprice_p, winnerprice_p;
        EXIT WHEN item_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(lpad(id_p, 5) || lpad(title_p, 10) || lpad(description_p, 20) || lpad(endtime_p, 20) || lpad(startprice_p, 20) || lpad(winnerprice_p, 20));
    END LOOP;
END;


--get_item_category_function
DECLARE
    item_cursor   sys_refcursor;
    id_p          NUMBER;
    title_p       VARCHAR2(255);
    description_p VARCHAR2(255);
    endtime_p     DATE;
    startprice_p  NUMBER;
    winnerprice_p NUMBER;
    title_c       VARCHAR2(255);
BEGIN
    item_cursor := admin_package.get_item_category_function(23);
    DBMS_OUTPUT.PUT_LINE('[Items category list]');
    DBMS_OUTPUT.PUT_LINE(lpad('id', 5) || lpad('title', 10) || lpad('description', 20) || lpad('end time', 20) || lpad('start price', 20) || lpad('winner price', 20) || lpad('category', 20));
    LOOP
        FETCH item_cursor
        INTO id_p, title_p, description_p, endtime_p, startprice_p, winnerprice_p, title_c;
        EXIT WHEN item_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(lpad(id_p, 5) || lpad(title_p, 10) || lpad(description_p, 20) || lpad(endtime_p, 20) || lpad(startprice_p, 20) || lpad(winnerprice_p, 20) || lpad(title_c, 20));
    END LOOP;
END;
SELECT *
FROM CATEGORY;
SELECT *
FROM ITEM_CATEGORY_VIEW;
SELECT *
FROM ITEMSCATEGORY;

--get_current_auction_function
DECLARE
    auction_cursor sys_refcursor;
    id_p           NUMBER;
    startdate_p    DATE;
    categoryid_p   NUMBER;
BEGIN
    auction_cursor := admin_package.get_current_auction_function(TO_DATE('31/12/2022', 'DD/MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE('[Information about current auction]');
    DBMS_OUTPUT.PUT_LINE(lpad('id', 5) || lpad('category id', 20) || lpad('start date', 20) );
    LOOP
        FETCH auction_cursor
        INTO id_p, categoryid_p, startdate_p ;
        EXIT WHEN auction_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(lpad(id_p, 5) || lpad(categoryid_p, 20) || lpad(startdate_p, 20) );
    END LOOP;
END;

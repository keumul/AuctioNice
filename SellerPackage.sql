--DROP PACKAGE seller_package;

CREATE OR REPLACE PACKAGE seller_package AS
    PROCEDURE insert_item_procedure(
        title_p VARCHAR2,
        description_p VARCHAR2,
        userid_p INT,
        endtime_p DATE,
        startprice_p INT,
        typeid_p INT);
    PROCEDURE signup_procedure(
        email_p IN VARCHAR2,
        password_p IN VARCHAR2,
        username_P IN VARCHAR2);
    PROCEDURE signin_procedure(
        p_login IN OUT VARCHAR2,
        p_password IN VARCHAR2);
    PROCEDURE actualize_item_procedure(itemid_p INT);
    FUNCTION get_item_function(item IN NUMBER) RETURN SYS_REFCURSOR;
    FUNCTION get_item_category_function(type_ INT) RETURN SYS_REFCURSOR;
    PROCEDURE delete_items_category(itemid_p number);
    PROCEDURE delete_item_procedure(id_p number);
    PROCEDURE delete_auction_items(auctionid_p number);
    PROCEDURE add_items_category_procedure(id_p number, itemid_p number, categoryid_p number);
    PROCEDURE add_items_auction_procedure(
        auctionid_p INT,
        itemid_p INT,
        count_p INT);

END seller_package;


CREATE OR REPLACE PACKAGE BODY seller_package AS
-- ------------------------ [DELETE ITEMS CATEGORY] ------------------------------------
--DROP PROCEDURE delete_items_category_procedure;
    PROCEDURE delete_items_category(
        itemid_p number)
        IS
    BEGIN
        DELETE
        FROM ItemsCategory
        WHERE itemid = itemid_p;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in delete_items_category');
    END delete_items_category;

-- ------------------------ [ADD ITEMS CATEGORY] ------------------------------------
--DROP PROCEDURE add_items_category_procedure;
    PROCEDURE add_items_category_procedure(
        id_p number,
        itemid_p number,
        categoryid_p number)
        IS
    BEGIN
        INSERT INTO ItemsCategory
            (id, itemid, categoryid)
        VALUES (id_p, itemid_p, categoryid_p);
        COMMIT ;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in add_items_category_procedure');
    END add_items_category_procedure;
-- ------------------------ [ADD ITEM] ------------------------------------
--DROP PROCEDURE insert_item_procedure;
    PROCEDURE insert_item_procedure(
        title_p VARCHAR2,
        description_p VARCHAR2,
        userid_p INT,
        endtime_p DATE,
        startprice_p INT,
        typeid_p INT)
        IS
        count_p INT;
        NOT_FOUND_TYPE EXCEPTION;
        INVALID_PRICE EXCEPTION;
    BEGIN
        SELECT COUNT(*) INTO count_p FROM Item;
        IF (count_p = 0) THEN
            RAISE NOT_FOUND_TYPE;
        ELSIF (startprice_p < 0) THEN
            RAISE INVALID_PRICE;
        ELSE
            INSERT INTO Item
            (title,
             description,
             userid,
             endTime,
             startprice,
             typeId)
            VALUES (title_p,
                    description_p,
                    userid_p,
                    endtime_p,
                    startprice_p,
                    typeid_p);
            COMMIT ;
        END IF;
    EXCEPTION
        WHEN NOT_FOUND_TYPE
            THEN RAISE_APPLICATION_ERROR(-20003, 'Cannot find type!');
        WHEN INVALID_PRICE
            THEN RAISE_APPLICATION_ERROR(-20003, 'Invalid price!');
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR(-20007, SQLERRM);
    END;
--
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
--
-- ------------------------ [DELETE ITEM] ------------------------------------
    --DROP PROCEDURE delete_item_procedure
    PROCEDURE delete_item_procedure(
        id_p number)
        IS
    BEGIN
        seller_package.delete_items_category(id_p);
        DELETE
        FROM Item
        WHERE id = id_p;
        COMMIT ;
    EXCEPTION
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR
                (-20010, 'Something went wrong with delete_item_procedure');
    END delete_item_procedure;

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
-- ------------------------ [ADD ITEMS AUCTION] ------------------------------------
--DROP PROCEDURE add_items_auction_procedure;
    PROCEDURE add_items_auction_procedure(
        auctionid_p INT,
        itemid_p INT,
        count_p INT)
        IS
        count_ int;
        ITEM_EXISTS EXCEPTION;
    BEGIN
        SELECT COUNT(*)
        INTO count_
        FROM ItemsAuction
        WHERE itemid = itemid_p;
        IF (count_ > 0) THEN
            RAISE ITEM_EXISTS;
        ELSE
            INSERT INTO ItemsAuction
                (auctionid, itemid, count)
            VALUES (auctionid_p, itemid_p, count_p);
            COMMIT ;
        END IF;
    EXCEPTION
        WHEN ITEM_EXISTS
            THEN RAISE_APPLICATION_ERROR
                (-20010, 'Item already exists in auction!');
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR
                (-20010, 'Something went wrong with add_items_auction_procedure');
    END add_items_auction_procedure;
--
-- ------------------------ [ACTUALIZE ITEMS] ------------------------------------
    PROCEDURE actualize_item_procedure(
        itemid_p INT)
        IS
        count_p int;
        date_p  date;
        price   int;
        NON_ACTUAL_DATE EXCEPTION;
    BEGIN
        SELECT userid, endtime, winnerprice
        INTO count_p, date_p, price
        FROM item
        WHERE id = itemid_p;
        IF (date_p < TRUNC(SYSDATE))
            AND price != 0 THEN
            UPDATE Users
            SET ACCOUNT = ACCOUNT + price
            WHERE id = count_p;
            UPDATE Item
            SET winnerprice = 0,
                endTime     = TRUNC(SYSDATE - 1)
            WHERE id = itemid_p;
            COMMIT ;
        ELSE
            RAISE NON_ACTUAL_DATE;
        END IF;
    EXCEPTION
        WHEN NON_ACTUAL_DATE
            THEN RAISE_APPLICATION_ERROR
                (-20010, 'Item is not actual!');
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR
                (-20010, 'Something went wrong with Actualize_Item');
    END;

------------------------ [SIGN UP] -------------------------------------------------
--DROP PROCEDURE signup_procedure;
    PROCEDURE signup_procedure(
        email_p IN VARCHAR2,
        password_p IN VARCHAR2,
        username_P IN VARCHAR2) IS
    BEGIN
        INSERT INTO users (email, password, username, role_id)
        VALUES (email_p, ORA_HASH(password_p), username_p, 2);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20001, 'Username already exists');
    END signup_procedure;

------------------------ [SIGN IN] -------------------------------------------------
--DROP PROCEDURE signin_procedure;
    PROCEDURE signin_procedure(
        p_login IN OUT VARCHAR2,
        p_password IN VARCHAR2
    )
        IS
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

        IF (user_found != 1)
        THEN
            RAISE NO_DATA_FOUND;
        END IF;

        SELECT email
        INTO p_login
        FROM users
        WHERE email = p_login
        AND ORA_HASH(p_password) = password;

    EXCEPTION
        WHEN NULL_PARAMETER
            THEN RAISE_APPLICATION_ERROR(-20005, 'Some parameters cannot be null!');
        WHEN NO_DATA_FOUND
            THEN RAISE_APPLICATION_ERROR(-20003, 'Cannot find user!');
        WHEN OTHERS
            THEN RAISE_APPLICATION_ERROR(-20007, SQLERRM);
    END signin_procedure;
END seller_package;

SELECT *
FROM USERS;




--     PROCEDURE insert_item_procedure +
--     PROCEDURE signup_procedure +
--     PROCEDURE signin_procedure +
--     PROCEDURE actualize_item_procedure(itemid_p INT) +
--     FUNCTION get_item_function(item IN ITEM.ID%type) RETURN SYS_REFCURSOR;
--     FUNCTION get_item_category_function(type_ INT) RETURN SYS_REFCURSOR;
--     PROCEDURE delete_items_category(itemid_p INT) +
--     PROCEDURE delete_item_procedure(id_p INT) +
--     PROCEDURE delete_auction_items(auctionid_p INT) +
--     PROCEDURE add_items_category_procedure(id_p INT, itemid_p INT, categoryid_p INT); +
--     PROCEDURE add_items_auction_procedure +
----------------------------------- [TEST] -----------------------------------
-- seller sign up
BEGIN
    seller_package.signup_procedure('meow@gmail.com', '1111', 'meow');
END;

SELECT *
FROM USERS;

-- seller login
DECLARE
    login_ VARCHAR2(255) := 'seller1';
BEGIN
    seller_package.signin_procedure(login_, '1111');
END;


-- seller add item
DECLARE
    title_p       VARCHAR2(255) := 'item1';
    description_p VARCHAR2(255) := 'item1';
    userid_p      INT           := 81;
    endtime_p     DATE          := TO_DATE('31/12/2022', 'DD/MM/YYYY');
    startprice_p  INT           := 100;
    typeid_p      INT           := 1;
BEGIN
    seller_package.insert_item_procedure(title_p, description_p, userid_p, endtime_p, startprice_p, typeid_p);
END;

SELECT *
FROM ITEM;

-- seller add item to category
DECLARE
    id_p         INT := 1;
    itemid_p     INT := 23;
    categoryid_p INT := 1;
BEGIN
    seller_package.add_items_category_procedure(id_p, itemid_p, categoryid_p);
END;

SELECT *
FROM ITEMSCATEGORY;

-- seller delete category
DECLARE
    id_p INT := 22;
BEGIN
    seller_package.delete_items_category(id_p);
END;

SELECT *
FROM ITEMSCATEGORY;

-- seller delete item
DECLARE
    id_p INT := 22;
BEGIN
    seller_package.delete_item_procedure(id_p);
END;

SELECT *
FROM ITEM;

--seller delete auction items
DECLARE
    id_p INT := 2;
BEGIN
    seller_package.delete_auction_items(id_p);
END;

SELECT *
FROM ITEMSAUCTION;

-- seller add item to auction
DECLARE
    count_p     INT := 3;
    itemid_p    INT := 23;
    auctionid_p INT := 2;
BEGIN
    seller_package.add_items_auction_procedure(auctionid_p, itemid_p, count_p);
END;

SELECT *
FROM ITEM;
SELECT *
FROM AUCTION;
SELECT *
FROM ITEMSAUCTION;


--seller actualize item
SELECT *
FROM ITEM;
DECLARE
    id_p INT := 23;
BEGIN
    seller_package.actualize_item_procedure(id_p);
END;


--get_item_function
DECLARE
    item_cursor   sys_refcursor;
    id_p          NUMBER;
    title_p       VARCHAR2(255);
    description_p VARCHAR2(255);
    endtime_p     DATE;
    startprice_p  NUMBER;
    winnerprice_p NUMBER;
BEGIN
    item_cursor := seller_package.get_item_function(23);
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
    item_cursor := seller_package.get_item_category_function(23);
    DBMS_OUTPUT.PUT_LINE('[Items category list]');
    DBMS_OUTPUT.PUT_LINE(lpad('id', 5) || lpad('title', 10) || lpad('description', 20) || lpad('end time', 20) || lpad('start price', 20) || lpad('winner price', 20) || lpad('category', 20));
    LOOP
        FETCH item_cursor
        INTO id_p, title_p, description_p, endtime_p, startprice_p, winnerprice_p, title_c;
        EXIT WHEN item_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(lpad(id_p, 5) || lpad(title_p, 10) || lpad(description_p, 20) || lpad(endtime_p, 20) || lpad(startprice_p, 20) || lpad(winnerprice_p, 20) || lpad(title_c, 20));
    END LOOP;
END;
